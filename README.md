# Radio Blacklist

A Cyberpunk 2077 mod: tick the vanilla radio stations you never want to hear, and the
game stops putting them on by itself. A blacklisted station is skipped when you get into
a vehicle, when you cycle stations with the radio button (in a vehicle or on foot), and
when the pocket radio comes back on after a scene, a call or a ride. Blacklisted
stations are also hidden from the radio list; to hear one again, untick it.

Author: Sylvanas Cry (Nexus: SylvanasCry).

Status: 0.1.0, not published yet. Checked in game on 2026-11-24 (game 2.5, with
RadioExt and Maelstrom Radio installed): the settings page with Ukrainian texts, hidden
stations in the vehicle and pocket radio list, replacement on getting into other
people's vehicles, the radio turning off when every station is blacklisted, Maelstrom
Radio left alone. Checked on 2026-11-25: cycling with the radio button (Radioport
setting "cycle stations") in a vehicle and on foot, the on-screen notice setting, and
installing the zip through Vortex ("Install From File").

## Requirements

- [redscript](https://www.nexusmods.com/cyberpunk2077/mods/1511)
- [Codeware](https://www.nexusmods.com/cyberpunk2077/mods/7780) (ScriptableService, localization)
- [Mod Settings](https://www.nexusmods.com/cyberpunk2077/mods/4885) (the checkboxes)

## Settings

Mod Settings, page "Radio Blacklist": one checkbox per vanilla station, in frequency
order like the radio list. The labels are the game's own station names
(`Gameplay-Devices-Radio-RadioStation*` keys), so they follow the game language.
Custom stations added by other mods (RadioExt) are not listed and are never touched.

The mod's own texts are translated to English, Ukrainian and Russian; other languages
fall back to English.

"Show replacements on screen" (off by default) shows a short HUD notice whenever the
mod switches a station or turns the radio off, for example
`Radio Blacklist: 96,1 «Ритуал-ФМ» -> 99,9 «Імпульс»`.

"Debug log" (off by default) writes what the mod does to the CET game log
(`bin/x64/plugins/cyber_engine_tweaks/gamelog.log`, lines tagged `[RadioBlacklist]`).

## How it works

Read in the game scripts (REDmod sources dated 2026-03-02, game 2.31 or older).

- The vehicle radio station is picked by the engine. The mod checks it when the vehicle
  reports a station (`VehicleComponent.OnVehicleRadioStationInitialized`,
  `PlayerPuppet.OnVehicleRadioStationChanged`) and after the radio button
  (`VehicleComponent.OnVehicleRadioEvent`). A blacklisted station is replaced with the
  next allowed one when the player is cycling, and with a random allowed one otherwise.
- The pocket radio is checked in `PocketRadio.TurnOn`, which every way of turning it on
  goes through. A blacklisted station is replaced with the next allowed one.
- The radio list (`VehiclesManagerDataHelper.GetRadioStations`, used by the vehicle
  radio and the Radioport) leaves blacklisted stations out. RadioExt builds its list on
  top of this function, so its custom stations stay and its own cycling skips the hidden
  ones too. An earlier version let a hand-picked blacklisted station through; that
  needed fragile rules, because the vehicle reports stray previous stations on every
  entry (checked in game, 2026-11-24).
- When every vanilla station is blacklisted, a vanilla station that starts by itself
  (a new vehicle picks one at random) is turned off instead of replaced: a station that
  is not in the radio list must not play (checked in game, 2026-11-24, that leaving it
  on looks wrong). Custom stations keep playing.
- Only vanilla station indices 0-14 (`ERadioStationList`) are handled. Custom stations
  use 15 and up and are left alone.
- While a quest scene runs in a vehicle (`VehicleScene` status effect tag) the mod does
  nothing, so scripted radio moments stay as the quest set them.

## Compatibility

- **RadioExt** (custom stations such as Maelstrom Radio). Read in RadioExt's code:
  it numbers its stations right after the vanilla ones, starting at
  `RadioStationDataProvider.GetStationsCount()` (15 today), and overrides
  `VehicleObject.GetCurrentRadioIndex` so that a vehicle reports the custom station's
  number while one plays. The mod treats every number outside the vanilla range as
  someone else's and never touches it (checked in game, 2026-11-24: Maelstrom Radio was
  left alone). Another custom-radio mod could report its stations differently; this
  numbering is RadioExt's convention, not the game's.
- **Cycling with the radio button and RadioExt.** In a vehicle the button calls the
  engine's `NextRadioReceiverStation`, which knows only vanilla stations, so cycling
  never reaches custom stations. This is a RadioExt limitation, not this mod's: RadioExt
  only observes that call, with an author's note `TODO: Make this properly change the
  station, also for custom ones` (read in its code). On foot RadioExt cycles by itself
  through the radio list, which this mod hands over without blacklisted stations, so
  custom stations are reached there (checked in game, 2026-11-25). To be repeated in
  the Compatibility section of the Nexus page.
- **New vanilla stations** (HKGN 102.0 arrived in 2.x as index 14). The vanilla range
  comes from `GetStationsCount()`, not from a constant in this mod, and RadioExt uses the
  same function, so both shift together. A new station would have no checkbox until the
  mod is updated: it is simply never blocked.

## Out of scope

Radios and jukeboxes placed in the world (`RadioController`, `JukeboxController`),
including the radio in V's apartment, are not touched and will not be: they have their
own station logic, and covering them would open a wide field of edge cases and
requests (decided 2026-11-24). The mod covers the vehicle radio and the Radioport only.

## Planned for 1.1

When every vanilla station is blacklisted, offer a choice in Mod Settings: turn the
radio off (as now) or play a random station from the radio list instead. Idea, not
built yet (agreed 2026-11-24):

- The list comes from `VehiclesManagerDataHelper.GetRadioStations`, which RadioExt
  extends with its stations (read in RadioExt's code), so custom stations show up there
  without this mod knowing about RadioExt.
- Start the pick the way the radio list does: `QuickSlotsManager.SendRadioEvent(true,
  true, index)`. RadioExt intercepts it for its own indices.
- Without RadioExt the list holds only "No station", so the option falls back to
  turning the radio off. No optional file and no hard dependency.
- To check in game: RadioExt switches the vehicle to its active station 0.1 s after
  entering, which may race with this switch; starting a station on the player's behalf
  on entry may show odd notifications.

## Planned: toggle all stations

A way to tick or untick every station at once instead of one by one (asked
2026-11-24). Not checked yet: Mod Settings has no plain buttons, so this would be a
checkbox or a choice list whose change handler sets all station fields; whether the
other checkboxes on the open page redraw at once has to be tested in game.

## Build

```
python build.py            # dist/RadioBlacklist.zip (no version in the name, see build.py)
python build.py --deploy   # also copy the scripts into the game for testing
python build.py --check    # compile offline first, with every installed redscript mod
```

`--deploy` and `--check` need the game folder: pass `--game <path>` or set the
`CP77_GAME_DIR` environment variable.

## Permissions

The source is public so that anyone can see what the mod does. It has no open-source
license: all rights are reserved by the author, Sylvanas Cry.

- You may install and use the mod, and read and study the code.
- Please do not re-upload the mod or a modified copy to Nexus Mods or anywhere else.
  Ask first by opening an issue in this repository.
- Official releases come only from this repository and the author's own mod pages.

Cyberpunk 2077, its radio stations and their names belong to CD PROJEKT RED. This mod
contains no game files: station names are read from the game at runtime.
