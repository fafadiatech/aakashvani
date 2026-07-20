from __future__ import annotations

import shutil
import subprocess
from pathlib import Path


class BellPlayer:
    def __init__(self, bell_file: Path, no_play: bool = False) -> None:
        self._bell_file = bell_file
        self._no_play = no_play

    def play(self) -> None:
        if self._no_play:
            return
        if not self._bell_file.exists():
            raise FileNotFoundError(f"Bell file not found: {self._bell_file}")

        command = self._build_command()
        subprocess.run(command, check=True)

    def _build_command(self) -> list[str]:
        if shutil.which("aplay"):
            return ["aplay", str(self._bell_file)]
        if shutil.which("paplay"):
            return ["paplay", str(self._bell_file)]
        if shutil.which("ffplay"):
            return ["ffplay", "-nodisp", "-autoexit", str(self._bell_file)]
        raise RuntimeError("No supported audio player found. Install aplay, paplay, or ffplay.")
