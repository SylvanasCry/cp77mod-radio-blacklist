"""Build Radio Blacklist.

Outputs (next to this script):
  dist/RadioBlacklist-<version>.zip  (install it in Vortex with "Install From File")

With --deploy the scripts are also copied straight into the game folder
(r6/scripts/RadioBlacklist) for quick testing without Vortex.

--deploy and --check need the game folder: pass --game or set CP77_GAME_DIR.

With --check the scripts are compiled offline with the game's redscript compiler
(engine/tools/scc.exe) together with every other installed redscript mod, in
build/scc. On errors scc also shows a "Compilation error" message box.
scc silently compiles nothing from folders under %TEMP%, hence build/.
"""
import argparse
import os
import shutil
import subprocess
import sys
import zipfile
from pathlib import Path

VERSION = "0.1.0"
ROOT = Path(__file__).resolve().parent
SRC = ROOT / "src"
SCRIPTS = Path("r6/scripts/RadioBlacklist")


def build() -> Path:
    dist = ROOT / "dist"
    dist.mkdir(exist_ok=True)
    archive = dist / f"RadioBlacklist-{VERSION}.zip"
    with zipfile.ZipFile(archive, "w", zipfile.ZIP_DEFLATED) as zf:
        for path in sorted(SRC.rglob("*")):
            if path.is_file():
                zf.write(path, path.relative_to(SRC).as_posix())
    return archive


def deploy(game: Path) -> Path:
    target = game / SCRIPTS
    if target.exists():
        shutil.rmtree(target)
    shutil.copytree(SRC / SCRIPTS, target)
    return target


def check(game: Path) -> bool:
    work = ROOT / "build" / "scc"
    if work.exists():
        shutil.rmtree(work)
    scripts = work / "scripts"
    cache = work / "cache"
    cache.mkdir(parents=True)
    shutil.copytree(
        game / "r6" / "scripts",
        scripts / "r6",
        ignore=lambda folder, names: ["RadioBlacklist"] if Path(folder) == game / "r6" / "scripts" else [],
    )
    for path in (game / "red4ext" / "plugins").rglob("*.reds"):
        target = scripts / "plugins" / path.relative_to(game / "red4ext" / "plugins")
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
    shutil.copytree(SRC / SCRIPTS, scripts / "r6" / "RadioBlacklist")
    shutil.copy2(game / "r6" / "cache" / "final.redscripts", cache)
    result = subprocess.run(
        [str(game / "engine" / "tools" / "scc.exe"), "-compile", str(scripts), "-customCacheDir", str(cache)],
        cwd=game,
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
    )
    output = result.stdout + result.stderr
    lines = [line for line in output.splitlines() if not line.endswith(".reds")]
    print("\n".join(lines))
    return "Compiling files in" in output and "[ERROR" not in output


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--deploy", action="store_true", help="also copy the scripts into the game")
    parser.add_argument("--check", action="store_true", help="compile offline with all installed redscript mods")
    parser.add_argument("--game", default=os.environ.get("CP77_GAME_DIR"), help="game folder (default: CP77_GAME_DIR)")
    args = parser.parse_args()
    game = Path(args.game) if args.game else None
    if (args.check or args.deploy) and (game is None or not (game / "bin" / "x64" / "Cyberpunk2077.exe").is_file()):
        parser.error("--deploy and --check need the game folder: pass --game or set CP77_GAME_DIR")
    if args.check and not check(game):
        print("check failed")
        sys.exit(1)
    print(f"built {build()}")
    if args.deploy:
        print(f"deployed to {deploy(game)}")


if __name__ == "__main__":
    main()
