"""Move files or folders to the Windows Recycle Bin without showing a console."""

import ctypes
import os
import sys
from ctypes import wintypes


class SHFILEOPSTRUCTW(ctypes.Structure):
    _fields_ = [
        ("hwnd", wintypes.HWND),
        ("wFunc", wintypes.UINT),
        ("pFrom", wintypes.LPCWSTR),
        ("pTo", wintypes.LPCWSTR),
        ("fFlags", wintypes.WORD),
        ("fAnyOperationsAborted", wintypes.BOOL),
        ("hNameMappings", ctypes.c_void_p),
        ("lpszProgressTitle", wintypes.LPCWSTR),
    ]


def main():
    paths = [os.path.abspath(path) for path in sys.argv[1:] if os.path.exists(path)]
    if not paths:
        return
    operation = SHFILEOPSTRUCTW()
    operation.wFunc = 3  # FO_DELETE
    operation.pFrom = "\0".join(paths) + "\0\0"
    operation.fFlags = 0x0040 | 0x0010 | 0x0400  # recycle, no confirmation, no error UI
    ctypes.windll.shell32.SHFileOperationW(ctypes.byref(operation))


if __name__ == "__main__":
    main()
