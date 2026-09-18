# Windows executable build

This build uses ATHENA's application code and its bundled Windows sequence-design tools. It keeps the original Mac and Windows batch scripts available.

## Build on Windows

1. Install the [64-bit Python 3.7.9 Windows installer](https://www.python.org/downloads/release/python-379/). Python 3.7 is needed for the Qt 5.12 Windows wheel. It is end of life, so use it only in the build environment.
2. Open PowerShell in the ATHENA repository root. Confirm that the Python launcher sees the correct interpreter:

   ```powershell
   py -3.7-64 --version
   py -3.7-64 -m venv .venv-windows
   ```

3. Run the build:

   ```powershell
   .\windows-build\build.ps1
   ```

If PowerShell blocks the script, use a process-scoped policy for this terminal and retry:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\windows-build\build.ps1
```

The result is `dist\Athena.exe`. The script installs the pinned dependencies, verifies their imports, generates version information, and runs PyInstaller. Open the executable on Windows and check that you can load a sample PLY, run a sequence tool, save its output, and take a screenshot. Qt 5.13 and newer have a [known screenshot regression in ATHENA](https://github.com/lcbb/athena/issues/11), so the build uses Qt 5.12.6.

## Build with GitHub Actions

Push these changes to the repository's default branch, then open **Actions → Build Windows EXE → Run workflow**. Download the **Athena-Windows** artifact after the run completes. The workflow builds on a Windows runner and checks that the application starts. PyInstaller cannot generate a Windows executable directly from Linux.

The executable has not been code signed. Test its graphical display and the PERDIX, METIS, DAEDALUS2, and TALOS tools on a Windows machine before distributing it.
