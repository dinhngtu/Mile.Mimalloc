@setlocal
@echo off

rem Change to the current folder.
cd "%~dp0"

rem Remove the output folder for a fresh compile.
rd /s /q Output

rem Initialize Visual Studio environment
set VisualStudioInstallerFolder="%ProgramFiles(x86)%\Microsoft Visual Studio\Installer"
if %PROCESSOR_ARCHITECTURE%==x86 set VisualStudioInstallerFolder="%ProgramFiles%\Microsoft Visual Studio\Installer"
pushd %VisualStudioInstallerFolder%
for /f "usebackq tokens=*" %%i in (`vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
  set VisualStudioInstallDir=%%i
)
popd
call "%VisualStudioInstallDir%\VC\Auxiliary\Build\vcvarsall.bat" x86

git -C mimalloc checkout -f
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
git -C mimalloc clean -fxd
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
git -C mimalloc apply ..\0001-Secure-build-props.patch
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
git -C mimalloc apply ..\0001-Fix-cross-build.patch
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%

rem Build Mimalloc x86
mkdir Output\x86-secure
pushd Output\x86-secure
cmake ..\..\mimalloc -A Win32 -DMI_OVERRIDE=ON -DMI_SECURE=ON
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --config=Release -j
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

rem Build Mimalloc x64
mkdir Output\x64-secure
pushd Output\x64-secure
cmake ..\..\mimalloc -A x64 -DMI_OVERRIDE=ON -DMI_SECURE=ON
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --config=Release -j
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

rem Build Mimalloc arm64
mkdir Output\arm64-secure
pushd Output\arm64-secure
cmake ..\..\mimalloc -A ARM64 -DMI_OVERRIDE=ON -DMI_SECURE=ON
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
cmake --build . --config=Release -j
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
popd

rem Build all targets
MSBuild -binaryLogger:Output\BuildAllTargets.binlog -m BuildAllTargets.proj
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%

rem Extract files from NuGet package to folder
7z x Output\Mile.Mimalloc.nupkg "-o.\Output\Mile.Mimalloc"
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%

@endlocal
