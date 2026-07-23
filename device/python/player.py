from __future__ import annotations

import shutil
import subprocess
import tempfile
import urllib.request
from pathlib import Path


class BellPlayer:
    """Plays local bell files, remote clip URLs, and TTS text via system tools."""

    def __init__(self, bell_file: Path, no_play: bool = False) -> None:
        self._bell_file = bell_file
        self._no_play = no_play

    def play(self) -> None:
        self.play_file(self._bell_file)

    def play_file(self, path: Path) -> None:
        if self._no_play:
            return
        if not path.exists():
            raise FileNotFoundError(f"Audio file not found: {path}")

        command = self._build_file_command(path)
        subprocess.run(command, check=True)

    def play_url(self, url: str) -> None:
        if self._no_play:
            return
        if not url:
            raise ValueError("Missing audio URL")

        suffix = Path(url.split("?", 1)[0]).suffix or ".wav"
        with tempfile.NamedTemporaryFile(suffix=suffix, delete=False) as tmp:
            tmp_path = Path(tmp.name)

        try:
            urllib.request.urlretrieve(url, tmp_path)  # noqa: S310 - device fetches trusted API media
            self.play_file(tmp_path)
        finally:
            tmp_path.unlink(missing_ok=True)

    def speak(self, text: str, voice_id: str | None = None) -> None:
        if self._no_play:
            return
        if not text.strip():
            raise ValueError("TTS text is empty")

        command = self._build_tts_command(text, voice_id)
        subprocess.run(command, check=True)

    def _build_file_command(self, path: Path) -> list[str]:
        if shutil.which("aplay"):
            return ["aplay", str(path)]
        if shutil.which("paplay"):
            return ["paplay", str(path)]
        if shutil.which("ffplay"):
            return ["ffplay", "-nodisp", "-autoexit", str(path)]
        raise RuntimeError("No supported audio player found. Install aplay, paplay, or ffplay.")

    def _build_tts_command(self, text: str, voice_id: str | None) -> list[str]:
        language = self._language_from_voice(voice_id)
        if shutil.which("espeak-ng"):
            cmd = ["espeak-ng", text]
            if language:
                cmd[1:1] = ["-v", language]
            return cmd
        if shutil.which("espeak"):
            cmd = ["espeak", text]
            if language:
                cmd[1:1] = ["-v", language]
            return cmd
        if shutil.which("say"):
            return ["say", text]
        raise RuntimeError("No supported TTS engine found. Install espeak-ng or espeak.")

    @staticmethod
    def _language_from_voice(voice_id: str | None) -> str | None:
        if not voice_id:
            return None
        # Voice ids look like "hi-IN-F" / "en-IN-M" — map to espeak language codes.
        lowered = voice_id.lower()
        if lowered.startswith("hi"):
            return "hi"
        if lowered.startswith("mr"):
            return "mr"
        if lowered.startswith("en"):
            return "en"
        return None
