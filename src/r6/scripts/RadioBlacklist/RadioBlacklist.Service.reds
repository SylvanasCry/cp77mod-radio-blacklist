module RadioBlacklist

/**
 * Holds the settings and the blacklist rules.
 *
 * Only vanilla stations (ERadioStationList, indices 0-14) are ever touched. Anything
 * else, such as -1 (no station) or custom stations added by other mods, is left alone.
 * Blacklisted stations are also hidden from the radio list, so the blacklist is absolute:
 * to hear such a station again, the player unticks it in the settings.
 */
public class RadioBlacklistService extends ScriptableService {
    private let m_config: ref<RadioBlacklistConfig>;

    private let m_lastCycleTime: Float;

    public static func Get() -> ref<RadioBlacklistService> {
        return GameInstance.GetScriptableServiceContainer()
            .GetService(n"RadioBlacklist.RadioBlacklistService") as RadioBlacklistService;
    }

    private cb func OnInitialize() {
        this.m_lastCycleTime = -100.0;
        this.m_config = new RadioBlacklistConfig();
        ModSettings.RegisterListenerToClass(this.m_config);
    }

    public func IsVanilla(station: Int32) -> Bool {
        return station >= 0 && station < RadioStationDataProvider.GetStationsCount();
    }

    /**
     * Returns true when the station must not play now.
     */
    public func IsBlocked(station: Int32) -> Bool {
        if !this.IsVanilla(station) || !IsDefined(this.m_config) {
            return false;
        }
        return this.m_config.IsChecked(station);
    }

    /**
     * The player cycled stations with the radio button.
     */
    public func MarkCycle(game: GameInstance) {
        this.m_lastCycleTime = this.Now(game);
        this.Log(s"cycle at \(this.m_lastCycleTime)");
    }

    /**
     * True for about a second after the player cycled stations with the radio button.
     */
    public func IsCycling(game: GameInstance) -> Bool {
        return this.Now(game) - this.m_lastCycleTime < 1.0;
    }

    /**
     * The next allowed station after the given one, in radio list order; -1 if none.
     */
    public func NextAllowed(station: Int32) -> Int32 {
        let count = RadioStationDataProvider.GetStationsCount();
        let current = station;
        let i = 0;
        while i < count {
            current = EnumInt(RadioStationDataProvider.GetNextStationPocketRadio(current));
            if !this.IsBlocked(current) {
                return current;
            }
            i += 1;
        }
        return -1;
    }

    /**
     * A random allowed station; -1 if none. Skips Minimal Techno like the game's own
     * random pick (RadioStationDataProvider.GetRandomStation), unless it is the only
     * allowed station.
     */
    public func RandomAllowed() -> Int32 {
        let allowed: array<Int32>;
        let minimalTechno = EnumInt(ERadioStationList.MINIMAL_TECHNO);
        let count = RadioStationDataProvider.GetStationsCount();
        let i = 0;
        while i < count {
            if i != minimalTechno && !this.IsBlocked(i) {
                ArrayPush(allowed, i);
            }
            i += 1;
        }
        if ArraySize(allowed) == 0 {
            return this.IsBlocked(minimalTechno) ? -1 : minimalTechno;
        }
        return allowed[RandRange(0, ArraySize(allowed))];
    }

    /**
     * The station to play instead of a blocked one: the next one when the player is
     * cycling, a random one otherwise.
     */
    public func Replacement(game: GameInstance, station: Int32) -> Int32 {
        if this.IsCycling(game) {
            return this.NextAllowed(station);
        }
        return this.RandomAllowed();
    }

    /**
     * Quest scenes may set a station on purpose; leave them alone.
     */
    public func IsSceneActive(player: ref<GameObject>) -> Bool {
        return IsDefined(player) && StatusEffectSystem.ObjectHasStatusEffectWithTag(player, n"VehicleScene");
    }

    /**
     * Switches the player's vehicle away from a blocked station. When every vanilla
     * station is blacklisted there is nothing to switch to, so the radio is turned off:
     * a station missing from the radio list must not play. Custom stations (RadioExt)
     * report indices 15 and up, are never blocked and are never turned off.
     * Returns the station the vehicle plays afterwards (-1 when off).
     */
    public func FixVehicle(vehicle: wref<VehicleObject>, reason: String) -> Int32 {
        if !IsDefined(vehicle) || !vehicle.IsRadioReceiverActive() {
            return -1;
        }
        let station = Cast<Int32>(vehicle.GetCurrentRadioIndex());
        let player = GetPlayer(vehicle.GetGame());
        if !IsDefined(player) || GetMountedVehicle(player) != vehicle {
            return station;
        }
        if this.IsSceneActive(player) {
            this.Log(s"\(reason): station \(station), vehicle scene, skipped");
            return station;
        }
        if !this.IsBlocked(station) {
            return station;
        }
        let replacement = this.Replacement(vehicle.GetGame(), station);
        this.Log(s"\(reason): vehicle station \(station) blocked, replacement \(replacement)");
        this.Notify(vehicle.GetGame(), station, replacement);
        if replacement == -1 {
            let off = new VehicleRadioEvent();
            off.toggle = false;
            off.setStation = false;
            off.station = -1;
            vehicle.QueueEvent(off);
            return -1;
        }
        vehicle.SetRadioReceiverStation(Cast<Uint32>(replacement));
        vehicle.GetBlackboard().SetName(
            GetAllBlackboardDefs().Vehicle.VehRadioStationName,
            vehicle.GetRadioReceiverStationName()
        );
        return replacement;
    }

    public func Log(message: String) {
        if IsDefined(this.m_config) && this.m_config.debugLog {
            ModLog(n"RadioBlacklist", message);
        }
    }

    /**
     * With the debug log on, also shows a replacement on the HUD ("A -> B", or "A -> off").
     */
    public func Notify(game: GameInstance, station: Int32, replacement: Int32) {
        if !IsDefined(this.m_config) || !this.m_config.debugLog {
            return;
        }
        let to = replacement == -1 ? "off" : this.StationName(replacement);
        let message: SimpleScreenMessage;
        message.isShown = true;
        message.duration = 8.0;
        message.message = s"Radio Blacklist: \(this.StationName(station)) -> \(to)";
        GameInstance.GetBlackboardSystem(game)
            .Get(GetAllBlackboardDefs().UI_Notifications)
            .SetVariant(GetAllBlackboardDefs().UI_Notifications.WarningMessage, ToVariant(message), true);
    }

    private func StationName(station: Int32) -> String {
        let key = RadioStationDataProvider.GetChannelName(IntEnum<ERadioStationList>(station));
        return GetLocalizedTextByKey(StringToName(key));
    }

    private func Now(game: GameInstance) -> Float {
        return EngineTime.ToFloat(GameInstance.GetEngineTime(game));
    }
}
