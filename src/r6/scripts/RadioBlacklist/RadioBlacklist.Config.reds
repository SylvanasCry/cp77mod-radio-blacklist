module RadioBlacklist

/**
 * Mod Settings page: one checkbox per vanilla station, ordered by frequency as in the
 * radio list. Station labels are the game's own localization keys, so they show the
 * station name in the current UI language. Custom stations (RadioExt) are not listed.
 */
public class RadioBlacklistConfig extends IScriptable {
    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationDownTempo")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockDownTempo: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationAggroIndie")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockAggroIndustrial: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationGrowlFm")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockGrowl: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationJazz")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockJazz: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationElectroIndie")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockElectroIndustrial: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationMinimalTechno")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockMinimalTechno: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationMetal")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockMetal: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationPop")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockPop: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationImpulseFM")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockImpulse: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationHipHop")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockHipHop: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationEdgerunners")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockEdgerunners: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationAggroTechno")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockAggroTechno: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationLatino")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockLatino: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationAttRock")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockAttitudeRock: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Category")
    @runtimeProperty("ModSettings.displayName", "Gameplay-Devices-Radio-RadioStationDarkStar")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-StationDescription")
    public let blockDarkStar: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Display")
    @runtimeProperty("ModSettings.displayName", "RadioBlacklist-ShowNotice")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-ShowNoticeDescription")
    public let showNotice: Bool = false;

    @runtimeProperty("ModSettings.mod", "Radio Blacklist")
    @runtimeProperty("ModSettings.category", "RadioBlacklist-Debug")
    @runtimeProperty("ModSettings.displayName", "RadioBlacklist-DebugLog")
    @runtimeProperty("ModSettings.description", "RadioBlacklist-DebugLogDescription")
    public let debugLog: Bool = false;

    /**
     * Returns true when the given vanilla station (ERadioStationList value) is checked.
     */
    public func IsChecked(station: Int32) -> Bool {
        switch IntEnum<ERadioStationList>(station) {
            case ERadioStationList.AGGRO_INDUSTRIAL:
                return this.blockAggroIndustrial;
            case ERadioStationList.ELECTRO_INDUSTRIAL:
                return this.blockElectroIndustrial;
            case ERadioStationList.HIP_HOP:
                return this.blockHipHop;
            case ERadioStationList.AGGRO_TECHNO:
                return this.blockAggroTechno;
            case ERadioStationList.DOWNTEMPO:
                return this.blockDownTempo;
            case ERadioStationList.ATTITUDE_ROCK:
                return this.blockAttitudeRock;
            case ERadioStationList.POP:
                return this.blockPop;
            case ERadioStationList.LATINO:
                return this.blockLatino;
            case ERadioStationList.METAL:
                return this.blockMetal;
            case ERadioStationList.MINIMAL_TECHNO:
                return this.blockMinimalTechno;
            case ERadioStationList.JAZZ:
                return this.blockJazz;
            case ERadioStationList.GROWL:
                return this.blockGrowl;
            case ERadioStationList.DARK_STAR:
                return this.blockDarkStar;
            case ERadioStationList.IMPULSE_FM:
                return this.blockImpulse;
            case ERadioStationList.EDGE_RUNNERS:
                return this.blockEdgerunners;
        }
        return false;
    }
}
