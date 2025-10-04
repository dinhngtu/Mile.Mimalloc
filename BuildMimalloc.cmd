@rem
@rem PROJECT:   Mouri Internal Library Essentials
@rem FILE:      BuildMimalloc.cmd
@rem PURPOSE:   Build Mimalloc via vcpkg
@rem
@rem LICENSE:   The MIT License
@rem
@rem MAINTAINER: MouriNaruto (Kenji.Mouri@outlook.com)
@rem

@setlocal
@echo off

rem Change to the current folder.
cd "%~dp0Mile.Mimalloc.Vcpkg"

rem Bootstrap vcpkg
call bootstrap-vcpkg.bat

rem Build Mimalloc via vcpkg
vcpkg install %VcpkgOptions% mimalloc[override,secure]:x86-windows
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
vcpkg install %VcpkgOptions% mimalloc[override,secure]:x64-windows
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%
vcpkg install %VcpkgOptions% mimalloc[override,secure]:arm64-windows
if %ERRORLEVEL% NEQ 0 exit /B %ERRORLEVEL%

@endlocal
