import hashlib, hmac, json, os, sys, time
from dotenv import load_dotenv
import requests

load_dotenv()
ACCESS_ID = os.environ["TUYA_ACCESS_ID"]
ACCESS_SECRET = os.environ["TUYA_ACCESS_SECRET"]
DEVICE_ID = os.environ["TUYA_DEVICE_ID"]
API_HOST = "https://openapi.tuyaus.com"

COMMANDS = [
    {"code": "switch_4", "value": sys.argv[1] == "on"}
]

def sha256(data):
    return hashlib.sha256(data.encode()).hexdigest()


def sign(method, path, body, token=None):
    t = str(int(time.time() * 1000))
    body_str = json.dumps(body, separators=(",", ":")) if body else ""
    string_to_sign = f"{method.upper()}\n{sha256(body_str)}\n\n{path}"
    sign_str = ACCESS_ID + (token or "") + t + string_to_sign
    sig = hmac.new(ACCESS_SECRET.encode(), sign_str.encode(), hashlib.sha256).hexdigest().upper()

    headers = {
        "client_id": ACCESS_ID,
        "sign": sig,
        "sign_method": "HMAC-SHA256",
        "t": t,
        "Content-Type": "application/json",
    }
    if token:
        headers["access_token"] = token
    return headers, body_str


def tuya_get(path, token=None):
    headers, _ = sign("GET", path, None, token)
    return requests.get(API_HOST + path, headers=headers, timeout=5).json()


def tuya_post(path, body, token=None):
    headers, body_str = sign("POST", path, body, token)
    return requests.post(API_HOST + path, headers=headers, data=body_str, timeout=5).json()


def main():
    try:
        data = tuya_get("/v1.0/token?grant_type=1")
        if not data.get("success"):
            raise RuntimeError(f"Token error: {data}")
        token = data["result"]["access_token"]

        data = tuya_post(
            f"/v1.0/iot-03/devices/{DEVICE_ID}/commands",
            {"commands": COMMANDS},
            token,
        )
        if not data.get("success") or data.get("result") is not True:
            raise RuntimeError(f"Command failed: {data}")
        print("Success!")
    except (requests.exceptions.RequestException, RuntimeError) as e:
        print(f"Failed: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
