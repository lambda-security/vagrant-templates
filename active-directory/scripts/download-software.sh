#!/bin/bash

if test -f "../files/Sysmon64.exe"; then
    if test $(stat -c%s "../files/Sysmon64.exe") -eq 0; then
        printf "%s\n" "[INFO] Downloading Sysmon64"
        curl -sL "https://live.sysinternals.com/Sysmon64.exe" -o "../files/Sysmon64.exe"
    else
        printf "%s\n" "[INFO] Sysmon64 already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading Sysmon64"
    curl -sL "https://live.sysinternals.com/Sysmon64.exe" -o "../files/Sysmon64.exe"
fi

if test -f "../files/PsExec64.exe"; then
    if test $(stat -c%s "../files/PsExec64.exe") -eq 0; then
        printf "%s\n" "[INFO] Downloading PsExec64"
        curl -sL "https://live.sysinternals.com/PsExec64.exe" -o "../files/PsExec64.exe"
    else
        printf "%s\n" "[INFO] PsExec64 already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading PsExec64"
    curl -sL "https://live.sysinternals.com/PsExec64.exe" -o "../files/PsExec64.exe"
fi

if test -f "../files/BgInfo.exe"; then
    if test $(stat -c%s "../files/BgInfo.exe") -eq 0; then
        printf "%s\n" "[INFO] Downloading BgInfo"
        curl -sL "https://live.sysinternals.com/Bginfo.exe" -o "../files/BgInfo.exe"
    else
        printf "%s\n" "[INFO] BgInfo already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading BgInfo"
    curl -sL "https://live.sysinternals.com/Bginfo.exe" -o "../files/BgInfo.exe"
fi

if test -f "../files/SQL2019-SSEI-Expr.exe"; then
    if test $(stat -c%s "../files/SQL2019-SSEI-Expr.exe") -eq 0; then
        printf "%s\n" "[INFO] Downloading SQL2019-SSEI-Expr"
        curl -sL "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe" -o "../files/SQL2019-SSEI-Expr.exe"
    else
        printf "%s\n" "[INFO] SQL2019-SSEI-Expr already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading SQL2019-SSEI-Expr"
    curl -sL "https://download.microsoft.com/download/7/f/8/7f8a9c43-8c8a-4f7c-9f92-83c18d96b681/SQL2019-SSEI-Expr.exe" -o "../files/SQL2019-SSEI-Expr.exe"
fi

if test -f "../files/googlechromestandaloneenterprise64.msi"; then
    if test $(stat -c%s "../files/googlechromestandaloneenterprise64.msi") -eq 0; then
        printf "%s\n" "[INFO] Downloading Google Chrome installer"
        curl -sL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -o "../files/googlechromestandaloneenterprise64.msi"
    else
        printf "%s\n" "[INFO] Google Chrome installer already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading Google Chrome installer"
    curl -sL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -o "../files/googlechromestandaloneenterprise64.msi"
fi

if test -f "../files/npp.exe"; then
    if test $(stat -c%s "../files/npp.exe") -eq 0; then
        printf "%s\n" "[INFO] Downloading Notepad++ installer"
        curl -sL "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe" -o "../files/npp.exe"
    else
        printf "%s\n" "[INFO] Notepad++ installer already downloaded, skipping"
    fi
else
    printf "%s\n" "[INFO] Downloading Notepad++ installer"
    curl -sL "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.6.2/npp.8.6.2.Installer.x64.exe" -o "../files/npp.exe"
fi
