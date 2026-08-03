import os
import shutil
import subprocess
from urllib.parse import unquote

import gi

gi.require_version("Nautilus", "4.1")
from gi.repository import GObject, Nautilus

ALACRITTY = shutil.which("alacritty") or "/run/current-system/sw/bin/alacritty"
ZED = shutil.which("zeditor") or shutil.which("zed") or "/run/current-system/sw/bin/zeditor"

_TERMINAL_LABEL = "Open in Alacritty"
_ZED_LABEL = "Open in Zed"


def _uri_to_path(uri):
    if not uri or not uri.startswith("file://"):
        return None
    return unquote(uri[len("file://"):])


class OpenInZedExtension(GObject.GObject, Nautilus.MenuProvider):
    def __init__(self):
        super().__init__()

    def _open_terminal(self, menu, paths):
        for path in paths:
            subprocess.Popen([ALACRITTY, "--working-directory", path])

    def _open_zed(self, menu, paths):
        subprocess.Popen([ZED, *paths])

    def get_file_items(self, files):
        paths = [_uri_to_path(f.get_uri()) for f in files]
        paths = [p for p in paths if p]
        if not paths:
            return []

        items = []
        if all(os.path.isdir(p) for p in paths):
            term = Nautilus.MenuItem(
                name="OpenInZedExtension::terminal",
                label=_TERMINAL_LABEL,
                tip="Open Alacritty in the selected folder",
            )
            term.connect("activate", self._open_terminal, paths)
            items.append(term)

        zed = Nautilus.MenuItem(
            name="OpenInZedExtension::zed",
            label=_ZED_LABEL,
            tip="Open selection in the Zed editor",
        )
        zed.connect("activate", self._open_zed, paths)
        items.append(zed)
        return items

    def get_background_items(self, folder):
        path = _uri_to_path(folder.get_uri())
        if not path:
            return []

        term = Nautilus.MenuItem(
            name="OpenInZedExtension::bg-terminal",
            label=_TERMINAL_LABEL,
            tip="Open Alacritty in this folder",
        )
        term.connect("activate", self._open_terminal, [path])

        zed = Nautilus.MenuItem(
            name="OpenInZedExtension::bg-zed",
            label=_ZED_LABEL,
            tip="Open this folder in the Zed editor",
        )
        zed.connect("activate", self._open_zed, [path])
        return [term, zed]