"""Request one Windows UAC-elevated, visible supervised console without flashing PowerShell."""

import ctypes
import json
import os
import sys
from ctypes import wintypes


class SHELLEXECUTEINFOW(ctypes.Structure):
    _fields_ = [
        ("cbSize", wintypes.DWORD),
        ("fMask", wintypes.ULONG),
        ("hwnd", wintypes.HWND),
        ("lpVerb", wintypes.LPCWSTR),
        ("lpFile", wintypes.LPCWSTR),
        ("lpParameters", wintypes.LPCWSTR),
        ("lpDirectory", wintypes.LPCWSTR),
        ("nShow", ctypes.c_int),
        ("hInstApp", wintypes.HINSTANCE),
        ("lpIDList", ctypes.c_void_p),
        ("lpClass", wintypes.LPCWSTR),
        ("hkeyClass", wintypes.HKEY),
        ("dwHotKey", wintypes.DWORD),
        ("hIconOrMonitor", wintypes.HANDLE),
        ("hProcess", wintypes.HANDLE),
    ]


def write_status(path, payload):
    temp = path + ".tmp"
    with open(temp, "w", encoding="utf-8") as handle:
        json.dump(payload, handle)
    os.replace(temp, path)


def main():
    runner, working_dir, status_path = sys.argv[1:4]
    SEE_MASK_NOCLOSEPROCESS = 0x00000040
    request = SHELLEXECUTEINFOW()
    request.cbSize = ctypes.sizeof(request)
    request.fMask = SEE_MASK_NOCLOSEPROCESS
    request.lpVerb = "runas"
    request.lpFile = os.environ.get("COMSPEC", r"C:\Windows\System32\cmd.exe")
    request.lpParameters = f'/d /c ""{runner}""'
    request.lpDirectory = working_dir
    request.nShow = 1
    accepted = bool(ctypes.windll.shell32.ShellExecuteExW(ctypes.byref(request)))
    if not accepted:
        write_status(status_path, {"state": "denied", "error": ctypes.get_last_error()})
        return
    pid = int(ctypes.windll.kernel32.GetProcessId(request.hProcess))
    ctypes.windll.kernel32.CloseHandle(request.hProcess)
    write_status(status_path, {"state": "accepted", "pid": pid})


if __name__ == "__main__":
    try:
        main()
    except Exception as exc:
        if len(sys.argv) >= 4:
            write_status(sys.argv[3], {"state": "error", "message": str(exc)})
