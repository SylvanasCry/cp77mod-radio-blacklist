module RadioBlacklist

/**
 * The radio list (vehicle radio and pocket radio): blacklisted stations are left out.
 * Record indices are radio list (UI) indices; -1 is "no station".
 */
@wrapMethod(VehiclesManagerDataHelper)
public static func GetRadioStations(player: ref<GameObject>) -> array<ref<IScriptable>> {
    let stations = wrappedMethod(player);
    let service = RadioBlacklistService.Get();
    if !IsDefined(service) {
        return stations;
    }
    let result: array<ref<IScriptable>>;
    for item in stations {
        let data = item as RadioListItemData;
        let keep = true;
        if IsDefined(data) && IsDefined(data.m_record) {
            let index = data.m_record.Index();
            if index >= 0 && index < RadioStationDataProvider.GetStationsCount() {
                keep = !service.IsBlocked(EnumInt(RadioStationDataProvider.GetRadioStationByUIIndex(index)));
            }
        }
        if keep {
            ArrayPush(result, item);
        }
    }
    return result;
}

/**
 * Quick slot radio commands: a plain toggle is the cycle button.
 */
@wrapMethod(QuickSlotsManager)
public func SendRadioEvent(toggle: Bool, setStation: Bool, stationIndex: Int32) -> Void {
    let service = RadioBlacklistService.Get();
    if IsDefined(service) && toggle && !setStation {
        service.MarkCycle(this.m_Player.GetGame());
    }
    wrappedMethod(toggle, setStation, stationIndex);
}

/**
 * Vehicle radio button: turns the radio on or cycles to the next station.
 */
@wrapMethod(VehicleComponent)
protected cb func OnVehicleRadioEvent(evt: ref<VehicleRadioEvent>) -> Bool {
    let service = RadioBlacklistService.Get();
    if IsDefined(service) && evt.toggle && !evt.setStation && this.m_radioState {
        service.MarkCycle(this.GetVehicle().GetGame());
    }
    let result = wrappedMethod(evt);
    if IsDefined(service) && evt.toggle && !evt.setStation {
        service.FixVehicle(this.GetVehicle(), "radio button");
    }
    return result;
}

/**
 * The engine has picked a station for the vehicle radio (getting into a vehicle).
 */
@wrapMethod(VehicleComponent)
protected cb func OnVehicleRadioStationInitialized(evt: ref<VehicleRadioStationInitialized>) -> Bool {
    let result = wrappedMethod(evt);
    let service = RadioBlacklistService.Get();
    if IsDefined(service) {
        service.FixVehicle(this.GetVehicle(), "station initialized");
    }
    return result;
}

/**
 * The vehicle radio has changed its station. The pocket radio listens to this event,
 * so a replaced station is passed on to it.
 */
@wrapMethod(PlayerPuppet)
protected cb func OnVehicleRadioStationChanged(evt: ref<VehicleRadioStationChanged>) -> Bool {
    let service = RadioBlacklistService.Get();
    if IsDefined(service) && evt.isActive {
        let station = Cast<Int32>(evt.radioIndex);
        service.Log(s"vehicle station changed to \(station)");
        let vehicle = GetMountedVehicle(this);
        if service.IsBlocked(station) && IsDefined(vehicle) {
            let actual = service.FixVehicle(vehicle, "station changed");
            if service.IsVanilla(actual) && !service.IsBlocked(actual) {
                evt.radioIndex = Cast<Uint32>(actual);
            }
        }
    }
    return wrappedMethod(evt);
}

/**
 * Every path that starts the pocket radio ends here: the cycle button, the end of a
 * scene or phone call, leaving a vehicle, loading a save.
 */
@wrapMethod(PocketRadio)
private func TurnOn(playSFX: Bool) -> Void {
    let service = RadioBlacklistService.Get();
    if IsDefined(service) && !service.IsSceneActive(this.m_player) {
        if service.IsBlocked(this.m_station) {
            let replacement = service.NextAllowed(this.m_station);
            service.Log(s"pocket radio station \(this.m_station) blocked, replacement \(replacement)");
            service.Notify(this.m_player.GetGame(), this.m_station, replacement);
            if replacement == -1 {
                this.m_station = -1;
                this.m_selectedStation = -1;
                this.TurnOff(false);
                return;
            }
            this.m_station = replacement;
            this.m_selectedStation = replacement;
        }
    }
    wrappedMethod(playSFX);
}
