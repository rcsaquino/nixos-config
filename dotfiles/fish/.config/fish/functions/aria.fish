function aria --description "Download with aria2c and show the target name"
    if test (count $argv) -eq 0
        echo "Usage: aria <URL|MAGNET|TORRENT_FILE> [aria2c options]" >&2
        return 2
    end

    set -l source $argv[1]
    set -l download_args $argv
    set -l metadata_dir
    set -l metadata_file
    set -l source_lower (string lower -- "$source")
    set -l is_magnet false
    set -l is_torrent false

    if string match -q 'magnet:*' -- "$source_lower"
        set is_magnet true
        set is_torrent true
    else if string match -qr '\.torrent(?:[?#].*)?$' -- "$source_lower"
        set is_torrent true
    end

    if test "$is_torrent" = true
        if test "$is_magnet" = true
            set metadata_dir (mktemp -d 2>/dev/null)
            if test -z "$metadata_dir"
                echo "aria: could not create a temporary directory for torrent metadata" >&2
                return 1
            end

            echo "Fetching torrent metadata..." >&2
            command aria2c --dir="$metadata_dir" --bt-metadata-only=true --bt-save-metadata=true --seed-time=0 "$source"
            if test $status -ne 0
                command rm -r -- "$metadata_dir"
                return 1
            end

            set metadata_file (find "$metadata_dir" -maxdepth 1 -type f -name '*.torrent' -print -quit)
            if test -z "$metadata_file"
                echo "aria: aria2c did not save torrent metadata" >&2
                command rm -r -- "$metadata_dir"
                return 1
            end
            set download_args[1] "$metadata_file"
        else if string match -qr '^(https?|ftp)://' -- "$source_lower"
            set metadata_dir (mktemp -d 2>/dev/null)
            if test -z "$metadata_dir"
                echo "aria: could not create a temporary directory for torrent metadata" >&2
                return 1
            end
            set metadata_file "$metadata_dir/download.torrent"

            python3 -c '
import sys
import urllib.request

request = urllib.request.Request(sys.argv[1], headers={"User-Agent": "aria/1.0"})
with urllib.request.urlopen(request, timeout=30) as response, open(sys.argv[2], "wb") as torrent:
    torrent.write(response.read())
' "$source" "$metadata_file"
            if test $status -ne 0
                echo "aria: could not fetch torrent metadata" >&2
                command rm -r -- "$metadata_dir"
                return 1
            end
        else if string match -q 'file://*' -- "$source_lower"
            set metadata_file (python3 -c 'import sys, urllib.parse, urllib.request; print(urllib.request.url2pathname(urllib.parse.urlsplit(sys.argv[1]).path))' "$source")
        else
            set metadata_file (string replace -r '^~' "$HOME" -- "$source")
        end

        set -l selected_files (python3 -c '
import os
import select
import hashlib
import sys
import termios
import tty


def bdecode(data):
    position = 0
    info_data = None

    def decode(depth=0):
        nonlocal info_data, position
        token = data[position:position + 1]
        if token == b"i":
            end = data.index(b"e", position)
            value = int(data[position + 1:end])
            position = end + 1
            return value
        if token == b"l":
            position += 1
            value = []
            while data[position:position + 1] != b"e":
                value.append(decode(depth + 1))
            position += 1
            return value
        if token == b"d":
            position += 1
            value = {}
            while data[position:position + 1] != b"e":
                key = decode(depth + 1)
                value_start = position
                value[key] = decode(depth + 1)
                if depth == 0 and key == b"info":
                    info_data = data[value_start:position]
            position += 1
            return value
        colon = data.index(b":", position)
        length = int(data[position:colon])
        position = colon + 1
        value = data[position:position + length]
        position += length
        return value

    return decode(), info_data


def text(value):
    decoded = value.decode("utf-8", errors="replace")
    return "".join(character if character >= " " and character != "\x7f" else "�" for character in decoded)


def size(value):
    units = ("B", "KiB", "MiB", "GiB", "TiB")
    amount = float(value)
    unit = units[0]
    for unit in units:
        if amount < 1024 or unit == units[-1]:
            break
        amount /= 1024
    return f"{int(amount)} {unit}" if unit == "B" else f"{amount:.1f} {unit}"


try:
    with open(os.path.expanduser(sys.argv[1]), "rb") as torrent:
        metadata, info_data = bdecode(torrent.read())
        info = metadata[b"info"]
        info_hash = hashlib.sha1(info_data).hexdigest()

    root = text(info.get(b"name.utf-8", info.get(b"name", b"Torrent")))
    if b"files" in info:
        files = []
        for item in info[b"files"]:
            parts = item.get(b"path.utf-8") or item[b"path"]
            files.append(("/".join([root, *(text(part) for part in parts)]), item[b"length"]))
    else:
        files = [(root, info[b"length"])]
except (IndexError, KeyError, OSError, TypeError, ValueError) as error:
    print(f"aria: could not read torrent metadata: {error}", file=sys.stderr)
    raise SystemExit(1)

try:
    terminal_in = open("/dev/tty", "r")
    terminal_out = open("/dev/tty", "w")
except OSError:
    terminal_in = None
    terminal_out = None

if not terminal_in:
    print("aria: an interactive terminal is required to select torrent files", file=sys.stderr)
    raise SystemExit(1)

terminal_fd = terminal_in.fileno()
original_settings = termios.tcgetattr(terminal_fd)
selection_path = os.path.expanduser(f"~/Downloads/aria2/state/{info_hash}.txt")
chosen = set(range(len(files)))
restored_selection = False
try:
    with open(selection_path, encoding="ascii") as selection_file:
        saved_selection = selection_file.read().strip()
    if saved_selection != "all":
        saved_indices = {int(index) - 1 for index in saved_selection.split(",")}
        if saved_indices and all(0 <= index < len(files) for index in saved_indices):
            chosen = saved_indices
            restored_selection = True
    elif saved_selection:
        restored_selection = True
except (OSError, ValueError):
    pass
cursor = 0
cancelled = False
message = "Restored previous selection." if restored_selection else ""
previous_frame = []


def render():
    try:
        columns, lines = os.get_terminal_size(terminal_fd)
    except OSError:
        columns, lines = 80, 24
    page_size = max(1, lines - 5)
    page_start = min(max(0, cursor - page_size + 1), max(0, len(files) - page_size))
    page_end = min(len(files), page_start + page_size)

    frame = [
        f"Torrent files — {len(chosen)}/{len(files)} selected",
        "↑/↓ navigate  Space toggle  Enter confirm  q cancel",
        "",
    ]
    for index in range(page_start, page_end):
        checkbox = "x" if index in chosen else " "
        suffix = f"  {size(files[index][1]):>10}"
        available = max(1, columns - len(suffix) - 4)
        path = files[index][0]
        if len(path) > available:
            path = "…" if available == 1 else "…" + path[-(available - 1):]
        line = f"[{checkbox}] {path:<{available}}{suffix}"
        if index == cursor:
            line = f"\x1b[7m{line}\x1b[0m"
        frame.append(line)
    more_below = len(files) - page_end
    frame.extend((f"↓ {more_below} more below" if more_below else "", message))

    if not previous_frame:
        terminal_out.write("\x1b[2J")
    for row in range(max(len(previous_frame), len(frame))):
        old_line = previous_frame[row] if row < len(previous_frame) else None
        new_line = frame[row] if row < len(frame) else ""
        if old_line != new_line:
            terminal_out.write(f"\x1b[{row + 1};1H\x1b[2K{new_line}")
    previous_frame[:] = frame
    terminal_out.flush()


try:
    tty.setraw(terminal_fd)
    terminal_out.write("\x1b[?1049h\x1b[?25l")
    while True:
        render()
        key = os.read(terminal_fd, 1)
        if not key:
            cancelled = True
            break
        if key == b"\x1b" and select.select([terminal_fd], [], [], 0.05)[0]:
            key += os.read(terminal_fd, 2)

        message = ""
        if key in (b"\x1b[A", b"k"):
            cursor = max(0, cursor - 1)
        elif key in (b"\x1b[B", b"j"):
            cursor = min(len(files) - 1, cursor + 1)
        elif key == b" ":
            if cursor in chosen:
                chosen.remove(cursor)
            else:
                chosen.add(cursor)
        elif key in (b"\r", b"\n"):
            if chosen:
                break
            message = "Select at least one file."
        elif key in (b"q", b"Q", b"\x03"):
            cancelled = True
            break
finally:
    termios.tcsetattr(terminal_fd, termios.TCSADRAIN, original_settings)
    terminal_out.write("\x1b[?25h\x1b[?1049l")
    terminal_out.flush()

if cancelled:
    raise SystemExit(130)

try:
    os.makedirs(os.path.dirname(selection_path), exist_ok=True)
    with open(selection_path, "w", encoding="ascii") as selection_file:
        if len(chosen) == len(files):
            selection_file.write("all\n")
        else:
            selection_file.write(",".join(str(index + 1) for index in sorted(chosen)) + "\n")
except OSError as error:
    print(f"aria: could not save torrent selection: {error}", file=sys.stderr)

if len(chosen) == len(files):
    print("all")
else:
    print(",".join(str(index + 1) for index in sorted(chosen)))
' "$metadata_file")
        set -l selection_status $status
        if test $selection_status -ne 0
            if test -n "$metadata_dir"
                command rm -r -- "$metadata_dir"
            end
            return $selection_status
        end

        if test "$selected_files" != all
            set -a download_args "--select-file=$selected_files"
        end
    end

    set -l name_source "$source"
    if test -n "$metadata_file"
        set name_source "$metadata_file"
    end
    set -l name (python3 -c '
import email.message
import os
import sys
import urllib.parse
import urllib.request

source = sys.argv[1]
extra_args = sys.argv[2:]


def output_name(args):
    for index, arg in enumerate(args):
        if arg in ("-o", "--out") and index + 1 < len(args):
            return args[index + 1]
        if arg.startswith("--out="):
            return arg.split("=", 1)[1]


def bdecode(data):
    position = 0

    def decode():
        nonlocal position
        token = data[position:position + 1]

        if token == b"i":
            end = data.index(b"e", position)
            value = int(data[position + 1:end])
            position = end + 1
            return value

        if token == b"l":
            position += 1
            value = []
            while data[position:position + 1] != b"e":
                value.append(decode())
            position += 1
            return value

        if token == b"d":
            position += 1
            value = {}
            while data[position:position + 1] != b"e":
                key = decode()
                value[key] = decode()
            position += 1
            return value

        colon = data.index(b":", position)
        length = int(data[position:colon])
        position = colon + 1
        value = data[position:position + length]
        position += length
        return value

    return decode()


def torrent_name(data):
    metadata = bdecode(data)
    info = metadata[b"info"]
    value = info.get(b"name.utf-8", info.get(b"name"))
    return value.decode("utf-8", errors="replace") if value else None


def disposition_name(header):
    if not header:
        return None
    message = email.message.Message()
    message["content-disposition"] = header
    return message.get_filename()


def url_name(url):
    parsed = urllib.parse.urlsplit(url)
    return os.path.basename(urllib.parse.unquote(parsed.path.rstrip("/")))


name = output_name(extra_args)
parsed = urllib.parse.urlsplit(source)

if not name and parsed.scheme == "magnet":
    query = urllib.parse.parse_qs(parsed.query)
    name = query.get("dn", [None])[0]
    if not name:
        name = query.get("xt", ["Magnet download"])[0].rsplit(":", 1)[-1]

is_remote = parsed.scheme in ("http", "https", "ftp")
is_torrent = parsed.path.lower().endswith(".torrent")

if not name and is_torrent:
    try:
        if is_remote:
            request = urllib.request.Request(source, headers={"User-Agent": "aria/1.0"})
            with urllib.request.urlopen(request, timeout=8) as response:
                name = torrent_name(response.read(16 * 1024 * 1024))
        else:
            path = urllib.request.url2pathname(parsed.path) if parsed.scheme == "file" else source
            with open(os.path.expanduser(path), "rb") as torrent:
                name = torrent_name(torrent.read())
    except (IndexError, KeyError, OSError, TypeError, ValueError, urllib.error.URLError):
        pass

if not name and is_remote:
    try:
        request = urllib.request.Request(source, method="HEAD", headers={"User-Agent": "aria/1.0"})
        with urllib.request.urlopen(request, timeout=5) as response:
            name = disposition_name(response.headers.get("Content-Disposition"))
            if not name:
                name = url_name(response.geturl())
    except (OSError, ValueError, urllib.error.URLError):
        pass

if not name:
    name = url_name(source) if parsed.scheme else os.path.basename(source.rstrip("/"))

name = (name or "Download").replace("\r", " ").replace("\n", " ")
print(name)
' "$name_source" $argv[2..-1])

    clear

    set -l columns $COLUMNS
    if not string match -qr '^[0-9]+$' -- "$columns"
        set columns (tput cols 2>/dev/null)
    end
    if not string match -qr '^[0-9]+$' -- "$columns"
        set columns 80
    end

    if test $columns -lt 5
        string shorten --max $columns -- "$name"
        echo
    else
        set -l display_name (string shorten --max (math "$columns - 4") -- "$name")
        set -l name_width (string length --visible -- "$display_name")
        set -l horizontal (string repeat -n (math "$name_width + 2") '─')

        printf '╭%s╮\n' "$horizontal"
        printf '│ %s │\n' (string pad --right --width $name_width -- "$display_name")
        printf '╰%s╯\n\n' "$horizontal"
    end

    command aria2c $download_args
    set -l aria_status $status

    if test -n "$metadata_dir"
        command rm -r -- "$metadata_dir"
    end

    return $aria_status
end
