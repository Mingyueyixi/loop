@echo off
setlocal enabledelayedexpansion

set PROJECT_ROOT=%~dp0
set OUTPUT_DIR=%PROJECT_ROOT%build
set DIST_DIR=%PROJECT_ROOT%dist
set EXE_NAME=loop.exe
set UPX_INSTALLED=0

:: UPX 压缩可执行文件
:OptimizeWithUPX
    if "%UPX_INSTALLED%"=="0" (
        echo UPX not available, using uncompressed version...
        copy /Y "%OUTPUT_DIR%\%EXE_NAME%" "%DIST_DIR%\%EXE_NAME%" >nul
        exit /b 1
    )
    
    echo Compressing with UPX...
    upx --best "%OUTPUT_DIR%\%EXE_NAME%" -o "%OUTPUT_DIR%\%EXE_NAME%.upx"
    if !ERRORLEVEL! equ 0 (
        move /Y "%OUTPUT_DIR%\%EXE_NAME%.upx" "%DIST_DIR%\%EXE_NAME%" >nul
        exit /b 0
    ) else (
        echo UPX compression failed, using uncompressed version...
        copy /Y "%OUTPUT_DIR%\%EXE_NAME%" "%DIST_DIR%\%EXE_NAME%" >nul
        exit /b 1
    )
goto :eof

:: 安装 UPX 工具
:InstallUPX
    echo Attempting to install UPX...
    where winget >nul 2>&1
    if !ERRORLEVEL! neq 0 (
        echo winget not available, cannot install UPX automatically.
        exit /b 1
    )
    
    winget install --id UPX.UPX -e --accept-package-agreements --accept-source-agreements
    if !ERRORLEVEL! equ 0 (
        set UPX_INSTALLED=1
        exit /b 0
    ) else (
        echo Failed to install UPX via winget.
        exit /b 1
    )
goto :eof

:: 检查并确保 UPX 可用
:EnsureUPX
    :: 使用 upx -h 命令检查其可用性
    where upx >nul 2>&1
    if !ERRORLEVEL! equ 0 (
        set UPX_INSTALLED=1
        exit /b 0
    )
    
    call :InstallUPX
    if !ERRORLEVEL! equ 0 (
        :: 刷新环境变量
        call :RefreshEnv
        where upx >nul 2>&1
        if !ERRORLEVEL! equ 0 (
            set UPX_INSTALLED=1
            exit /b 0
        )
    )
    exit /b 1
goto :eof

:: 刷新环境变量
:RefreshEnv
    set "PATH=%PATH%;%ProgramFiles%\UPX"
    set "PATH=%PATH%;%ProgramFiles(x86)%\UPX"
    exit /b 0
goto :eof

:: ========== 主程序 ===

:: 创建输出目录
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"

:: 编译和链接
pushd "%OUTPUT_DIR%"
cl /O1 /Os /MT /DNDEBUG /Gy /LTCG /Fo"%OUTPUT_DIR%\loop.obj" /Fe"%OUTPUT_DIR%\%EXE_NAME%" "%PROJECT_ROOT%loop.c"
link /OPT:REF /OPT:ICF "%OUTPUT_DIR%\loop.obj"
popd

:: 确保 UPX 可用并执行压缩
call :EnsureUPX
call :OptimizeWithUPX

:: 完成
echo Build complete. Output: "%DIST_DIR%\%EXE_NAME%"
endlocal