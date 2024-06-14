REM ���� ������ : 2015�� 8�� 18��
REM �Խñ� ���� : http://snoopybox.co.kr/1749
REM �ۼ���      : snoopy

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
echo     ��Ŭ�� �ؼ� ������ �������� �������ּ���.
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
echo     %~d0 ��Ʈ�� sources\boot.wim �Ǵ� boot\boot.sdi ������ �������� �ʽ��ϴ�.
echo.
echo     ������ �ٽ� Ȯ�����ּ���.
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
echo     ������ �߻��߽��ϴ�. ���� ��ũ������ �۵����� �ʽ��ϴ�.
echo.
echo     �⺻ ��ũ���� �������ּ���.
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
echo     �۾��� ���������� �Ϸ�Ǿ����ϴ�.
echo.
echo     ������Ͻø� Setup Windows 10 �޴��� ��Ÿ���ϴ�.
echo.
echo.
echo.
pause
exit