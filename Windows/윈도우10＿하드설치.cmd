REM 최종 수정일 : 2015년 8월 18일
REM 게시글 원문 : http://snoopybox.co.kr/1749
REM 작성자      : snoopy

@echo off

bcdedit /enum bootmgr > nul || goto _admin

if exist %~d0\sources\boot.wim (
    if exist %~d0\boot\boot.sdi (
        bcdedit /create {ramdiskoptions} /d "Setup Windows 10" || bcdedit /set {ramdiskoptions} description "Setup Windows 10"
        bcdedit /set {ramdiskoptions} ramdisksdidevice partition=%~d0 || goto _dynamic
        bcdedit /set {ramdiskoptions} ramdisksdipath \boot\boot.sdi
        setlocal enabledelayedexpansion
        for /f "tokens=1-5 usebackq delims=-" %%a in (`bcdedit /create /d "Setup Windows 10" /application osloader`) do (
            set first=%%a
            set last=%%e
            set guid=!first:~-9!-%%b-%%c-%%d-!last:~0,13!
        )
        bcdedit /set !guid! device ramdisk=[%~d0]\sources\boot.wim,{ramdiskoptions}
        bcdedit /set !guid! osdevice ramdisk=[%~d0]\sources\boot.wim,{ramdiskoptions}
        set bios=exe
        bcdedit /enum bootmgr | findstr bootmgfw.efi
        if not errorlevel 1 set bios=efi
        bcdedit /set !guid! path \windows\system32\winload.!bios!
        bcdedit /set !guid! systemroot \windows
        bcdedit /set !guid! winpe yes
        bcdedit /set !guid! detecthal yes
        bcdedit /displayorder !guid! /addlast
        bcdedit /timeout 10
        endlocal
        goto _success
    )
) > nul
goto _readme

:_admin
cls
echo.
echo.
echo.
echo     우클릭 해서 관리자 권한으로 실행해주세요.
echo.
echo.
echo.
pause
exit

:_readme
cls
echo.
echo.
echo.
echo     %~d0 루트에 sources\boot.wim 또는 boot\boot.sdi 파일이 존재하지 않습니다.
echo.
echo     사용법을 다시 확인해주세요.
echo.
echo.
echo.
pause
exit

:_dynamic
cls
echo.
echo.
echo.
echo     오류가 발생했습니다. 동적 디스크에서는 작동하지 않습니다.
echo.
echo     기본 디스크에서 실행해주세요.
echo.
echo.
echo.
pause
exit

:_success
cls
echo.
echo.
echo.
echo     작업이 성공적으로 완료되었습니다.
echo.
echo     재부팅하시면 Setup Windows 10 메뉴가 나타납니다.
echo.
echo.
echo.
pause
exit