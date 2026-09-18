"""Small checks used by the Windows PowerShell build script."""

import os
import struct
import sys


def main():
    if len(sys.argv) != 2:
        raise SystemExit("Usage: build_checks.py python-version|geometryloaders")

    if sys.argv[1] == "python-version":
        if sys.version_info[:2] != (3, 7) or struct.calcsize("P") != 8:
            raise SystemExit("64-bit Python 3.7 is required")
    elif sys.argv[1] == "geometryloaders":
        import PySide2

        path = os.path.join(os.path.dirname(PySide2.__file__), "plugins", "geometryloaders")
        if not os.path.isdir(path):
            raise SystemExit("PySide2 geometry loader plugins were not found: " + path)
        print(path)
    else:
        raise SystemExit("Unknown check: " + sys.argv[1])


if __name__ == "__main__":
    main()
