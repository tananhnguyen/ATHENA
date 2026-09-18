$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if ($env:OS -ne 'Windows_NT') {
    throw 'Build Athena.exe on Windows.'
}

$repo = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location $repo

if (-not (Test-Path '.venv-windows\Scripts\python.exe')) {
    python -c 'import struct, sys; assert sys.version_info[:2] == (3, 7) and struct.calcsize("P") == 8, "64-bit Python 3.7 is required"'
    if ($LASTEXITCODE -ne 0) { throw '64-bit Python 3.7 is required on PATH.' }
    python -m venv .venv-windows
    if ($LASTEXITCODE -ne 0) { throw 'Python 3.7 x64 is required.' }
}
$python = Join-Path $repo '.venv-windows\Scripts\python.exe'
& $python -c 'import struct, sys; assert sys.version_info[:2] == (3, 7) and struct.calcsize("P") == 8, "64-bit Python 3.7 is required"'
if ($LASTEXITCODE -ne 0) { throw 'The existing .venv-windows uses the wrong Python version.' }

& $python -m pip install -r windows-build\requirements.txt
if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
& $python -m pip check
if ($LASTEXITCODE -ne 0) { throw 'Dependency validation failed.' }
& $python -c 'from PySide2 import Qt3DCore, Qt3DExtras, Qt3DRender, QtQml, QtUiTools; import numpy, plyfile'
if ($LASTEXITCODE -ne 0) { throw 'Athena dependencies could not be imported.' }

& $python build_preflight.py
if ($LASTEXITCODE -ne 0) { throw 'Version generation failed.' }

$qtPlugins = (& $python -c 'import os, PySide2; print(os.path.join(os.path.dirname(PySide2.__file__), "plugins", "geometryloaders"))' | Select-Object -Last 1)
if ($LASTEXITCODE -ne 0 -or -not (Test-Path $qtPlugins)) {
    throw 'PySide2 geometry loader plugins were not found.'
}

$arguments = @(
    '-m', 'PyInstaller', 'src\main.py',
    '--clean', '--noconfirm', '--onefile', '--windowed',
    '--paths', $repo,
    '--name', 'Athena', '--icon', 'icon\athena.ico',
    '--version-file', 'version_info.txt',
    '--add-data', 'ui;ui',
    '--add-data', 'tools;tools',
    '--add-data', 'sample_inputs;sample_inputs',
    '--add-data', 'src\qml;qml',
    '--add-data', 'src\shaders;shaders',
    '--add-data', 'src\txt;txt',
    '--add-data', 'athena_version.py;.',
    '--add-binary', "$qtPlugins;qt5_plugins/geometryloaders"
)
& $python @arguments
if ($LASTEXITCODE -ne 0) { throw 'PyInstaller failed.' }
if (-not (Test-Path 'dist\Athena.exe')) { throw 'dist\Athena.exe was not created.' }
Write-Host "Built $repo\dist\Athena.exe"
