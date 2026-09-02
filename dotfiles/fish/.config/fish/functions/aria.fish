function aria --description "Download with aria2c and show the target name"
    if test (count $argv) -eq 0
        echo "Usage: aria <URL|MAGNET|TORRENT_FILE> [aria2c options]" >&2
        return 2
    end

    set -l source $argv[1]
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
' "$source" $argv[2..-1])

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

    command aria2c $argv
end
