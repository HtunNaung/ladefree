# --- PowerShell ½Å±¾ÉèÖÃ ---
# $ErrorActionPreference = "Stop"£ºµ±ÃüÁîÓöµ½·ÇÖÕÖ¹´íÎóÊ±£¬Á¢¼´Í£Ö¹½Å±¾Ö´ÐÐ¡£
# $ProgressPreference = "SilentlyContinue"£ºÒÖÖÆ Invoke-WebRequest µÈ Cmdlet µÄ½ø¶ÈÌõÏÔÊ¾¡£
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# --- ÑÕÉ«¶¨Òå (ÊÊÓÃÓÚ PowerShell) ---
# ÕâÐ©º¯ÊýÊ¹ÓÃ Write-Host Cmdlet ºÍ -ForegroundColor ²ÎÊýÀ´Êä³ö´øÑÕÉ«µÄÎÄ±¾¡£
# ×¢Òâ£ºÕâÐ©ÑÕÉ«ÔÚÏÖ´úµÄ Windows Terminal ºÍ PowerShell 7+ ÖÐÖ§³ÖÁ¼ºÃ£¬µ«ÔÚ¾É°æ¿ØÖÆÌ¨ÖÐ¿ÉÄÜÏÔÊ¾²»ÕýÈ·¡£
Function Write-Host-Green { param([string]$Message) Write-Host -ForegroundColor Green $Message }
Function Write-Host-Blue { param([string]$Message) Write-Host -ForegroundColor Blue $Message }
Function Write-Host-Yellow { param([string]$Message) Write-Host -ForegroundColor Yellow $Message }
Function Write-Host-Red { param([string]$Message) Write-Host -ForegroundColor Red $Message }
Function Write-Host-Purple { param([string]$Message) Write-Host -ForegroundColor DarkMagenta $Message } # PowerShell ÖÐµÄ×ÏÉ«Í¨³£ÊÇ DarkMagenta
Function Write-Host-Cyan { param([string]$Message) Write-Host -ForegroundColor Cyan $Message }

# --- ÅäÖÃ²¿·Ö ---
$LADEFREE_REPO_URL_BASE = "https://github.com/byJoey/ladefree" # Ladefree Ó¦ÓÃµÄ GitHub ²Ö¿â»ù´¡URL
$LADEFREE_REPO_BRANCH = "main" # Ladefree ²Ö¿âµÄ·ÖÖ§
$LADE_CLI_NAME = "lade.exe" # Lade CLI ¿ÉÖ´ÐÐÎÄ¼þÃû (Windows ÉÏÍ¨³£ÊÇ .exe)
# $env:ProgramFiles ÊÇ Windows ÉÏµÄ±ê×¼³ÌÐòÎÄ¼þÄ¿Â¼£¬ÀýÈç C:\Program Files
$LADE_INSTALL_PATH = "$env:ProgramFiles\LadeCLI" # Lade CLI µÄ±ê×¼°²×°Â·¾¶

# --- ×÷ÕßÐÅÏ¢ ---
# ×÷Õß£ºJoey
# ²©¿Í£ºjoeyblog.net
# Telegram Èº£ºhttps://t.me/+ft-zI76oovgwNmRh

# --- ¸¨Öúº¯Êý£ºÏÔÊ¾»¶Ó­ÐÅÏ¢ ---
Function Display-Welcome {
    Clear-Host # Çå³ý¿ØÖÆÌ¨ÆÁÄ»
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#        " -NoNewline; Write-Host-Blue "»¶Ó­Ê¹ÓÃ Lade CLI ¶à¹¦ÄÜ¹ÜÀí½Å±¾ v1.0.0" -NoNewline; Write-Host-Cyan "        #"
    Write-Host-Cyan "#                                                           #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green ""
    Write-Host "  >> ×÷Õß: Joey"
    Write-Host "  >> ²©¿Í: joeyblog.net"
    Write-Host "  >> Telegram Èº: https://t.me/+ft-zI76oovgwNmRh"
    Write-Host "  >> ²¿ÊðµÄ´úÂënote.jsÀ´×Ô https://github.com/eooce ÀÏÍõ "
    Write-Host ""
    Write-Host-Yellow "ÕâÊÇÒ»¸ö×Ô¶¯»¯ Lade Ó¦ÓÃ²¿ÊðºÍ¹ÜÀí¹¤¾ß£¬Ö¼ÔÚ¼ò»¯²Ù×÷¡£"
    Write-Host ""
    Read-Host "°´ Enter ¼ü¿ªÊ¼..." | Out-Null # µÈ´ýÓÃ»§°´ Enter ¼ü£¬²¢¶ªÆúÊäÈë
}

# --- ¸¨Öúº¯Êý£ºÏÔÊ¾¹¦ÄÜÇø±êÌâ ---
Function Display-SectionHeader {
    param([string]$Title) # ½ÓÊÜÒ»¸ö×Ö·û´®²ÎÊý×÷Îª±êÌâ
    Write-Host ""
    Write-Host-Purple "--- $Title ---"
    Write-Host-Purple "-----------------------------------"
}

# --- ¸¨Öúº¯Êý£º¼ì²éÃüÁîÊÇ·ñ´æÔÚ ---
Function Test-CommandExists {
    param([string]$Command) # ½ÓÊÜÒ»¸ö×Ö·û´®²ÎÊý×÷ÎªÃüÁîÃû
    # Get-Command ³¢ÊÔ²éÕÒÖ¸¶¨µÄÃüÁî¡£-ErrorAction SilentlyContinue ÒÖÖÆ´íÎóÐÅÏ¢¡£
    # Èç¹ûÕÒµ½ÃüÁî£¬Ëü½«·µ»ØÒ»¸ö¶ÔÏó£¬·ñÔò·µ»Ø $null¡£
    (Get-Command -Name $Command -ErrorAction SilentlyContinue) -ne $null
}

# --- ¸¨Öúº¯Êý£º¼ì²é Lade CLI ÊÇ·ñ´æÔÚÇÒ¿ÉÓÃ ---
Function Test-LadeCli {
    Test-CommandExists $LADE_CLI_NAME # µ÷ÓÃ Test-CommandExists ¼ì²é Lade CLI
}

# --- ¸¨Öúº¯Êý£ºÈ·±£ÒÑµÇÂ¼ Lade ---
Function Ensure-LadeLogin {
    Write-Host ""
    Write-Host-Purple "--- ¼ì²é Lade µÇÂ¼×´Ì¬ ---"
    # ³¢ÊÔÖ´ÐÐÒ»¸öÐèÒªÈÏÖ¤µÄ Lade ÃüÁî£¨ÀýÈç `lade apps list`£©¡£
    # Èç¹û¸ÃÃüÁîÊ§°Ü£¨Å×³ö´íÎó£©£¬Ôò±íÊ¾Î´µÇÂ¼»ò»á»°¹ýÆÚ¡£
    try {
        # Ê¹ÓÃ & ÔËËã·ûÖ´ÐÐÍâ²¿¿ÉÖ´ÐÐÎÄ¼þ¡£Out-Null ¶ªÆúÃüÁîµÄ±ê×¼Êä³ö¡£
        & lade apps list 
        Write-Host-Green "Lade ÒÑµÇÂ¼¡£"
    } catch {
        Write-Host-Yellow "Lade µÇÂ¼»á»°ÒÑ¹ýÆÚ»òÎ´µÇÂ¼¡£Çë¸ù¾ÝÌáÊ¾ÊäÈëÄúµÄ Lade µÇÂ¼Æ¾¾Ý¡£"
        try {
            & lade login # ÌáÊ¾ÓÃ»§½øÐÐµÇÂ¼
            Write-Host-Green "Lade µÇÂ¼³É¹¦£¡"
        } catch {
            Write-Host-Red "´íÎó£ºLade µÇÂ¼Ê§°Ü¡£Çë¼ì²éÓÃ»§Ãû/ÃÜÂë»òÍøÂçÁ¬½Ó¡£"
            exit 1 # µÇÂ¼Ê§°Ü£¬ÍË³ö½Å±¾
        }
    }
}

# --- ¹¦ÄÜº¯Êý£º²¿ÊðÓ¦ÓÃ ---
Function Deploy-App {
    Display-SectionHeader "²¿Êð Lade Ó¦ÓÃ"

    Ensure-LadeLogin # È·±£ÓÃ»§ÒÑµÇÂ¼

    $LADE_APP_NAME = Read-Host "ÇëÊäÈëÄúÒª²¿ÊðµÄ Lade Ó¦ÓÃÃû³Æ (ÀýÈç: my-ladefree-app):"
    # [string]::IsNullOrWhiteSpace ¼ì²é×Ö·û´®ÊÇ·ñÎª null¡¢¿Õ»ò½ö°üº¬¿Õ°××Ö·û
    if ([string]::IsNullOrWhiteSpace($LADE_APP_NAME)) {
        Write-Host-Yellow "Ó¦ÓÃÃû³Æ²»ÄÜÎª¿Õ¡£È¡Ïû²¿Êð¡£"
        return # ·µ»Øº¯Êý£¬²»¼ÌÐøÖ´ÐÐ²¿Êð
    }

    Write-Host "ÕýÔÚ¼ì²éÓ¦ÓÃ '$LADE_APP_NAME' ÊÇ·ñ´æÔÚ..."
    $app_exists = $false
    try {
        $appList = & lade apps list # »ñÈ¡Ó¦ÓÃÁÐ±í
        # -like ÔËËã·ûÓÃÓÚÍ¨Åä·ûÆ¥Åä¡£¼ì²éÁÐ±íÖÐÊÇ·ñ°üº¬Ó¦ÓÃÃû³Æ¡£
        if ($appList -like "*$LADE_APP_NAME*") {
            $app_exists = $true
        }
    } catch {
        # Èç¹û»ñÈ¡Ó¦ÓÃÁÐ±íÊ§°Ü£¬¿ÉÄÜÊÇÍøÂçÎÊÌâ»ò Lade CLI ÎÊÌâ£¬µ«ÎÒÃÇÈÔ³¢ÊÔ¼ÌÐø¡£
        Write-Host-Yellow "ÎÞ·¨»ñÈ¡Ó¦ÓÃÁÐ±íÒÔÑéÖ¤ÆäÊÇ·ñ´æÔÚ£¬¼Ù¶¨²»´æÔÚ»ò¼ÌÐø´´½¨/²¿Êð¡£"
    }

    if ($app_exists) {
        Write-Host-Green "Ó¦ÓÃ '$LADE_APP_NAME' ÒÑ´æÔÚ£¬½«Ö±½Ó²¿Êð¸üÐÂ¡£"
    } else {
        Write-Host-Yellow "Ó¦ÓÃ '$LADE_APP_NAME' ²»´æÔÚ£¬½«³¢ÊÔ´´½¨ÐÂÓ¦ÓÃ¡£"
        Write-Host-Cyan "×¢Òâ£º´´½¨Ó¦ÓÃ½«½»»¥Ê½Ñ¯ÎÊ 'Plan' ºÍ 'Region'£¬ÇëÊÖ¶¯Ñ¡Ôñ¡£"
        try {
            & lade apps create "$LADE_APP_NAME" # ³¢ÊÔ´´½¨Ó¦ÓÃ
            Write-Host-Green "Lade Ó¦ÓÃ´´½¨ÃüÁîÒÑ·¢ËÍ¡£"
        } catch {
            Write-Host-Red "´íÎó£ºLade Ó¦ÓÃ´´½¨Ê§°Ü¡£Çë¼ì²éÊäÈë»òÓ¦ÓÃÃû³ÆÊÇ·ñ¿ÉÓÃ¡£"
            return # ´´½¨Ê§°Ü£¬·µ»Øº¯Êý
        }
    }

    Write-Host ""
    Write-Host-Blue "--- ÕýÔÚÏÂÔØ ZIP ²¢²¿Êð Ladefree Ó¦ÓÃ (²»ÒÀÀµ Git) ---"
    # Join-Path Cmdlet °²È«µØÆ´½ÓÂ·¾¶£¬´¦Àí²»Í¬µÄÂ·¾¶·Ö¸ô·û¡£
    $ladefree_temp_download_dir = Join-Path $env:TEMP "ladefree_repo_download_$(Get-Random)"
    # New-Item -ItemType Directory -Force ´´½¨Ä¿Â¼£¬Èç¹û´æÔÚÔò²»±¨´í¡£Out-Null ÒÖÖÆÊä³ö¡£
    New-Item -ItemType Directory -Force -Path $ladefree_temp_download_dir | Out-Null

    $ladefree_download_url = "$LADEFREE_REPO_URL_BASE/archive/refs/heads/$LADEFREE_REPO_BRANCH.zip"
    $temp_ladefree_archive = Join-Path $ladefree_temp_download_dir "ladefree.zip"

    Write-Host "ÕýÔÚÏÂÔØ $LADEFREE_REPO_URL_BASE ($LADEFREE_REPO_BRANCH ·ÖÖ§) Îª ZIP °ü..."
    Write-Host "ÏÂÔØ URL: $ladefree_download_url"

    try {
        # Invoke-WebRequest ÊÇ PowerShell ÏÂÔØÎÄ¼þºÍÍøÒ³ÄÚÈÝµÄÖ÷Òª Cmdlet¡£
        Invoke-WebRequest -Uri $ladefree_download_url -OutFile $temp_ladefree_archive
    } catch {
        Write-Host-Red "´íÎó£ºÏÂÔØ Ladefree ²Ö¿â ZIP °üÊ§°Ü¡£Çë¼ì²é URL »òÍøÂçÁ¬½Ó¡£"
        # Remove-Item -Recurse -Force Ç¿ÖÆÉ¾³ýÄ¿Â¼¼°ÆäÄÚÈÝ£¬-ErrorAction SilentlyContinue ÒÖÖÆÉ¾³ý´íÎó¡£
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ÏÂÔØÊ§°Ü£¬·µ»Øº¯Êý
    }

    Write-Host "ÏÂÔØÍê³É£¬ÕýÔÚ½âÑ¹..."
    try {
        # Expand-Archive ÊÇ PowerShell ½âÑ¹ ZIP ÎÄ¼þµÄ Cmdlet¡£
        Expand-Archive -Path $temp_ladefree_archive -DestinationPath $ladefree_temp_download_dir -Force
    } catch {
        Write-Host-Red "´íÎó£º½âÑ¹ Ladefree ZIP °üÊ§°Ü¡£ÇëÈ·±£ 'Expand-Archive' ¹¦ÄÜ¿ÉÓÃ£¨PowerShell 5.0+ ÄÚÖÃ£©¡£"
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ½âÑ¹Ê§°Ü£¬·µ»Øº¯Êý
    }

    # ²éÕÒ½âÑ¹ºóµÄÓ¦ÓÃ³ÌÐòÄ¿Â¼ (ÀýÈç£¬ladefree-main)¡£
    # Get-ChildItem -Directory ½ö»ñÈ¡Ä¿Â¼£¬-Filter "ladefree-*" °´Ãû³Æ¹ýÂË¡£
    # Select-Object -ExpandProperty FullName ½öÑ¡ÔñÍêÕûÂ·¾¶¡£
    # Select-Object -First 1 È·±£Ö»È¡µÚÒ»¸öÆ¥ÅäÏî¡£
    $extracted_app_path = Get-ChildItem -Path $ladefree_temp_download_dir -Directory -Filter "ladefree-*" | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_app_path)) {
        Write-Host-Red "´íÎó£ºÎ´ÔÚÁÙÊ±ÏÂÔØÄ¿Â¼ÖÐÕÒµ½½âÑ¹ºóµÄ Ladefree Ó¦ÓÃ³ÌÐòÄ¿Â¼¡£"
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # Î´ÕÒµ½Ä¿Â¼£¬·µ»Øº¯Êý
    }

    Write-Host-Blue "ÕýÔÚ´Ó±¾µØ½âÑ¹Â·¾¶ $extracted_app_path ²¿Êðµ½ Lade£º$LADE_APP_NAME ..."
    Push-Location $extracted_app_path # ¸ü¸Äµ±Ç°¹¤×÷Ä¿Â¼µ½½âÑ¹Â·¾¶
    try {
        & lade deploy --app "$LADE_APP_NAME" # Ö´ÐÐ²¿ÊðÃüÁî
        $deploy_status = $LASTEXITCODE # »ñÈ¡Íâ²¿ÃüÁîµÄÍË³ö´úÂë
    } catch {
        Write-Host-Red "´íÎó£ºLade Ó¦ÓÃ²¿ÊðÊ§°Ü¡£Çë¼ì²é Ladefree ´úÂë±¾ÉíµÄÎÊÌâ»ò Lade Æ½Ì¨ÈÕÖ¾¡£"
        Pop-Location # »Ö¸´µ½Ö®Ç°µÄÄ¿Â¼
        Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue
        return # ²¿ÊðÊ§°Ü£¬·µ»Øº¯Êý
    }
    Pop-Location # »Ö¸´µ½Ö®Ç°µÄÄ¿Â¼

    Write-Host "ÇåÀíÁÙÊ±ÏÂÔØÄ¿Â¼ $ladefree_temp_download_dir..."
    Remove-Item -Path $ladefree_temp_download_dir -Recurse -Force -ErrorAction SilentlyContinue

    if ($deploy_status -ne 0) {
        Write-Host-Red "´íÎó£ºLade Ó¦ÓÃ²¿ÊðÊ§°Ü¡£Çë¼ì²é Ladefree ´úÂëÎÊÌâ»ò Lade Æ½Ì¨ÈÕÖ¾¡£"
        return # ²¿ÊðÊ§°Ü£¬·µ»Øº¯Êý
    }
    Write-Host-Green "Lade Ó¦ÓÃ²¿Êð³É¹¦£¡"

    Write-Host ""
    Write-Host-Cyan "--- ²¿ÊðÍê³É ---"
}

# --- ¹¦ÄÜº¯Êý£º²é¿´ËùÓÐÓ¦ÓÃ ---
Function View-Apps {
    Display-SectionHeader "²é¿´ËùÓÐ Lade Ó¦ÓÃ"

    Ensure-LadeLogin # È·±£ÓÃ»§ÒÑµÇÂ¼

    try {
        & lade apps list # Ö´ÐÐ²é¿´Ó¦ÓÃÁÐ±íÃüÁî
    } catch {
        Write-Host-Red "´íÎó£ºÎÞ·¨»ñÈ¡Ó¦ÓÃÁÐ±í¡£Çë¼ì²éÍøÂç»ò Lade CLI ×´Ì¬¡£"
    }
}

# --- ¹¦ÄÜº¯Êý£ºÉ¾³ýÓ¦ÓÃ ---
Function Delete-App {
    Display-SectionHeader "É¾³ý Lade Ó¦ÓÃ"

    Ensure-LadeLogin # È·±£ÓÃ»§ÒÑµÇÂ¼

    $APP_TO_DELETE = Read-Host "ÇëÊäÈëÄúÒªÉ¾³ýµÄ Lade Ó¦ÓÃÃû³Æ:"
    if ([string]::IsNullOrWhiteSpace($APP_TO_DELETE)) {
        Write-Host-Yellow "Ó¦ÓÃÃû³Æ²»ÄÜÎª¿Õ¡£È¡ÏûÉ¾³ý¡£"
        return
    }

    Write-Host-Red "¾¯¸æ£ºÄú¼´½«É¾³ýÓ¦ÓÃ '$APP_TO_DELETE'¡£´Ë²Ù×÷²»¿É³·Ïú£¡"
    $CONFIRM_DELETE = Read-Host "È·¶¨ÒªÉ¾³ýÂð£¿ (y/N):"
    $CONFIRM_DELETE = $CONFIRM_DELETE.ToLower() # ½«ÊäÈë×ª»»ÎªÐ¡Ð´

    if ($CONFIRM_DELETE -eq "y") {
        try {
            & lade apps remove "$APP_TO_DELETE" # ½« 'delete' ¸ü¸ÄÎª 'remove'
            Write-Host-Green "Ó¦ÓÃ '$APP_TO_DELETE' ÒÑ³É¹¦É¾³ý¡£"
        } catch {
            Write-Host-Red "´íÎó£ºÉ¾³ýÓ¦ÓÃ '$APP_TO_DELETE' Ê§°Ü¡£Çë¼ì²éÓ¦ÓÃÃû³ÆÊÇ·ñÕýÈ·»òÄúÊÇ·ñÓÐÈ¨ÏÞ¡£"
        }
    } else {
        Write-Host-Yellow "È¡ÏûÉ¾³ý²Ù×÷¡£"
    }
}

# --- ¹¦ÄÜº¯Êý£º²é¿´Ó¦ÓÃÈÕÖ¾ ---
Function View-AppLogs {
    Display-SectionHeader "²é¿´ Lade Ó¦ÓÃÈÕÖ¾"

    Ensure-LadeLogin # È·±£ÓÃ»§ÒÑµÇÂ¼

    $APP_FOR_LOGS = Read-Host "ÇëÊäÈëÄúÒª²é¿´ÈÕÖ¾µÄ Lade Ó¦ÓÃÃû³Æ:"
    if ([string]::IsNullOrWhiteSpace($APP_FOR_LOGS)) {
        Write-Host-Yellow "Ó¦ÓÃÃû³Æ²»ÄÜÎª¿Õ¡£È¡Ïû²é¿´ÈÕÖ¾¡£"
        return
    }

    Write-Host-Cyan "ÕýÔÚ²é¿´Ó¦ÓÃ '$APP_FOR_LOGS' µÄÊµÊ±ÈÕÖ¾ (°´ Ctrl+C Í£Ö¹)..."
    try {
        # lade logs µÄ -f ±êÖ¾Í¨³£±íÊ¾¡°¸úËæ¡±ÈÕÖ¾Êä³ö
        & lade logs -a "$APP_FOR_LOGS" -f
    } catch {
        Write-Host-Red "´íÎó£ºÎÞ·¨»ñÈ¡Ó¦ÓÃ '$APP_FOR_LOGS' µÄÈÕÖ¾¡£Çë¼ì²éÓ¦ÓÃÃû³ÆÊÇ·ñÕýÈ·»òÓ¦ÓÃÊÇ·ñÕýÔÚÔËÐÐ¡£"
    }
}

# --- ³õÊ¼»¯²½Öè (È·±£ Lade CLI ÒÑ°²×°) ---
Function Install-LadeCli {
    Display-SectionHeader "¼ì²é»ò°²×° Lade CLI"

    if (Test-LadeCli) {
        Write-Host-Green "Lade CLI ÒÑ°²×°£º$(Get-Command $LADE_CLI_NAME).Path"
        return $true # Lade CLI ÒÑ¾­´æÔÚ£¬·µ»Ø true
    }

    Write-Host-Yellow "Lade CLI Î´°²×°¡£ÕýÔÚ³¢ÊÔ×Ô¶¯°²×° Lade CLI..."

    $lade_release_url = "https://github.com/lade-io/lade/releases"
    $lade_temp_dir = Join-Path $env:TEMP "lade_cli_download_temp_$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $lade_temp_dir | Out-Null

    $os_type = "windows" # ÔÚ Windows ÉÏÓ²±àÂëÎª "windows"
    # Get-WmiObject Win32_Processor »ñÈ¡´¦ÀíÆ÷ÐÅÏ¢£¬Architecture ÊôÐÔ±íÊ¾¼Ü¹¹ÀàÐÍ¡£
    $arch_type = (Get-WmiObject Win32_Processor).Architecture

    $arch_suffix = ""
    # ¸ù¾Ý´¦ÀíÆ÷¼Ü¹¹ÉèÖÃÏÂÔØÎÄ¼þÃûºó×º
    switch ($arch_type) {
        0 { $arch_suffix = "-amd64" } # x86 ¼Ü¹¹
        9 { $arch_suffix = "-amd64" } # x64 ¼Ü¹¹
        6 { $arch_suffix = "-arm64" } # ARM64 ¼Ü¹¹
        default {
            Write-Host-Red "´íÎó£º²»Ö§³ÖµÄ Windows ¼Ü¹¹£º$arch_type"
            Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
            exit 1
        }
    }
    Write-Host-Blue "¼ì²âµ½ Windows ($((Get-WmiObject Win32_Processor).Caption)) ¼Ü¹¹¡£"

    # ¼ì²é±ØÒªµÄ¹¤¾ß£ºInvoke-WebRequest (PowerShell ÄÚÖÃ) »ò curl.exe (Èç¹ûÓÃ»§°²×°ÁË)
    if (-not (Test-CommandExists "curl.exe") -and -not (Test-CommandExists "Invoke-WebRequest")) {
        Write-Host-Red "´íÎó£ºÎ´ÕÒµ½ 'curl.exe' »ò 'Invoke-WebRequest' (PowerShell µÄÍøÂç¿Í»§¶Ë)¡£ÇëÈ·±£ PowerShell ÒÑ¸üÐÂ»ò curl ÒÑ°²×°¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    # ¼ì²é Expand-Archive (PowerShell ÄÚÖÃ)
    if (-not (Test-CommandExists "Expand-Archive")) {
        Write-Host-Red "´íÎó£ºÎ´ÕÒµ½ 'Expand-Archive' (PowerShell µÄ½âÑ¹ÃüÁî)¡£ÇëÈ·±£ PowerShell 5.0+ ÒÑ°²×°¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "ÕýÔÚ»ñÈ¡×îÐÂ°æ±¾µÄ Lade CLI..."
    try {
        # Invoke-RestMethod ÓÃÓÚµ÷ÓÃ RESTful Web ·þÎñ£¬»ñÈ¡ GitHub API µÄ JSON ÏìÓ¦¡£
        $latest_release_info = Invoke-RestMethod -Uri "https://api.github.com/repos/lade-io/lade/releases/latest"
        $latest_release_tag = $latest_release_info.tag_name # ´Ó JSON ÏìÓ¦ÖÐÌáÈ¡ tag_name
    } catch {
        Write-Host-Red "´íÎó£ºÎÞ·¨»ñÈ¡×îÐÂ°æ±¾µÄ Lade CLI¡£Çë¼ì²éÍøÂç»ò GitHub API ÏÞÖÆ¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($latest_release_tag)) {
        Write-Host-Red "´íÎó£ºÎÞ·¨È·¶¨×îÐÂ Lade CLI °æ±¾¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    $lade_version = $latest_release_tag
    Write-Host-Green "¼ì²âµ½×îÐÂ°æ±¾£º$lade_version"

    $filename_to_download = "lade-${os_type}${arch_suffix}.zip" # Lade CLI for Windows Í¨³£ÊÇ .zip
    $download_url = "$lade_release_url/download/$lade_version/$filename_to_download"
    $temp_archive = Join-Path $lade_temp_dir $filename_to_download

    Write-Host "ÏÂÔØ URL: $download_url"
    Write-Host "ÕýÔÚÏÂÔØ $filename_to_download µ½ $temp_archive..."
    try {
        Invoke-WebRequest -Uri $download_url -OutFile $temp_archive # ÏÂÔØÎÄ¼þ
    } catch {
        Write-Host-Red "´íÎó£ºÏÂÔØ Lade CLI Ê§°Ü¡£Çë¼ì²éÍøÂçÁ¬½Ó»ò URL ÊÇ·ñÕýÈ·¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Host "ÏÂÔØÍê³É£¬ÕýÔÚ½âÑ¹..."
    try {
        Expand-Archive -Path $temp_archive -DestinationPath $lade_temp_dir -Force # ½âÑ¹ ZIP ÎÄ¼þ
    } catch {
        Write-Host-Red "´íÎó£º½âÑ¹ ZIP ÎÄ¼þÊ§°Ü¡£ÇëÈ·±£ 'Expand-Archive' Cmdlet ¿ÉÓÃ (PowerShell 5.0+)¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # ÔÚ½âÑ¹ºóµÄÄ¿Â¼ÖÐ²éÕÒ Lade CLI ¿ÉÖ´ÐÐÎÄ¼þ¡£
    # -Recurse µÝ¹éËÑË÷×ÓÄ¿Â¼£¬-File ½ö²éÕÒÎÄ¼þ£¬-Filter ¹ýÂËÎÄ¼þÃû¡£
    $extracted_lade_path = Get-ChildItem -Path $lade_temp_dir -Recurse -File -Filter $LADE_CLI_NAME | Select-Object -ExpandProperty FullName | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($extracted_lade_path)) {
        Write-Host-Red "´íÎó£ºÔÚ½âÑ¹ºóµÄÁÙÊ±Ä¿Â¼ÖÐÎ´ÕÒµ½ '$LADE_CLI_NAME' ¿ÉÖ´ÐÐÎÄ¼þ¡£Çë¼ì²éÑ¹Ëõ°üÄÚÈÝ¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # È·±£Ä¿±ê°²×°Â·¾¶´æÔÚ
    if (-not (Test-Path $LADE_INSTALL_PATH)) {
        New-Item -ItemType Directory -Force -Path $LADE_INSTALL_PATH | Out-Null
    }

    Write-Host "ÕýÔÚ½« Lade CLI ÒÆ¶¯µ½ $LADE_INSTALL_PATH..."
    try {
        # Move-Item ÒÆ¶¯ÎÄ¼þ¡£-Force Ç¿ÖÆ¸²¸ÇÄ¿±ê£¨Èç¹û´æÔÚ£©¡£
        Move-Item -Path $extracted_lade_path -Destination (Join-Path $LADE_INSTALL_PATH $LADE_CLI_NAME) -Force
    } catch {
        Write-Host-Red "´íÎó£ºÒÆ¶¯ Lade CLI ÎÄ¼þÊ§°Ü¡£¿ÉÄÜÐèÒª¹ÜÀíÔ±È¨ÏÞ»òÄ¿Â¼²»´æÔÚ¡£"
        Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }

    # ½« Lade CLI Ìí¼Óµ½ÏµÍ³ PATH »·¾³±äÁ¿ (Èç¹ûÉÐÎ´Ìí¼Ó)
    # ÕâÍ¨³£ÐèÒª¹ÜÀíÔ±È¨ÏÞ²ÅÄÜÐÞ¸Ä»úÆ÷¼¶±ðµÄ»·¾³±äÁ¿¡£
    try {
        # [Environment]::GetEnvironmentVariable »ñÈ¡»·¾³±äÁ¿¡£
        $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
        # ¼ì²é PATH ÖÐÊÇ·ñÒÑ°üº¬°²×°Â·¾¶¡£
        if (-not ($currentPath -split ';' -contains $LADE_INSTALL_PATH)) {
            Write-Host-Yellow "ÕýÔÚ½« '$LADE_INSTALL_PATH' Ìí¼Óµ½ÏµÍ³ PATH¡£ÕâÐèÒª¹ÜÀíÔ±È¨ÏÞ¡£"
            $newPath = "$currentPath;$LADE_INSTALL_PATH"
            # [Environment]::SetEnvironmentVariable ÉèÖÃ»·¾³±äÁ¿¡£
            [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
            Write-Host-Green "Lade CLI °²×°Â·¾¶ÒÑÌí¼Óµ½ÏµÍ³ PATH¡£Äú¿ÉÄÜÐèÒªÖØÐÂÆô¶¯ PowerShell »á»°²ÅÄÜÊ¹ÆäÉúÐ§¡£"
        }
    } catch {
        Write-Host-Yellow "¾¯¸æ£ºÎÞ·¨½« Lade CLI Â·¾¶Ìí¼Óµ½ÏµÍ³ PATH »·¾³±äÁ¿¡£ÇëÊÖ¶¯Ìí¼Ó '$LADE_INSTALL_PATH' µ½ÄúµÄ PATH£¬ÒÔ±ã´ÓÈÎºÎÎ»ÖÃÔËÐÐ 'lade' ÃüÁî¡£"
    }

    Write-Host-Green "Lade CLI ÒÑ³É¹¦ÏÂÔØ¡¢½âÑ¹²¢°²×°µ½ $LADE_INSTALL_PATH"
    Remove-Item -Path $lade_temp_dir -Recurse -Force -ErrorAction SilentlyContinue
    return $true # Lade CLI °²×°³É¹¦
}


# --- Ö÷ÒªÖ´ÐÐÁ÷³Ì ---

# ÏÔÊ¾»¶Ó­Ò³Ãæ
Display-Welcome

# 2. È·±£ Lade CLI ÒÑ°²×°
# Èç¹û Install-LadeCli ·µ»Ø false (°²×°Ê§°Ü)£¬ÔòÍË³ö½Å±¾¡£
if (-not (Install-LadeCli)) {
    Write-Host-Red "´íÎó£ºLade CLI °²×°Ê§°Ü¡£½Å±¾½«ÍË³ö¡£"
    exit 1
}

# --- Ö÷²Ëµ¥ ---
while ($true) { # ÎÞÏÞÑ­»·£¬Ö±µ½ÓÃ»§Ñ¡ÔñÍË³ö
    Write-Host ""
    Write-Host-Cyan "#############################################################"
    Write-Host-Cyan "#          " -NoNewline; Write-Host-Blue "Lade ¹ÜÀíÖ÷²Ëµ¥" -NoNewline; Write-Host-Cyan "                          #"
    Write-Host-Cyan "#############################################################"
    Write-Host-Green "1. " -NoNewline; Write-Host "²¿Êð Ladefree Ó¦ÓÃ"
    Write-Host-Green "2. " -NoNewline; Write-Host "²é¿´ËùÓÐ Lade Ó¦ÓÃ"
    Write-Host-Green "3. " -NoNewline; Write-Host "É¾³ý Lade Ó¦ÓÃ"
    Write-Host-Green "4. " -NoNewline; Write-Host "²é¿´Ó¦ÓÃÈÕÖ¾"
    Write-Host-Green "5. " -NoNewline; Write-Host "Ë¢ÐÂ Lade µÇÂ¼×´Ì¬"
    Write-Host-Red "6. " -NoNewline; Write-Host "ÍË³ö"
    Write-Host-Cyan "-------------------------------------------------------------"
    $CHOICE = Read-Host "ÇëÑ¡ÔñÒ»¸ö²Ù×÷ (1-6):"

    switch ($CHOICE) { # ¸ù¾ÝÓÃ»§Ñ¡ÔñÖ´ÐÐÏàÓ¦º¯Êý
        "1" { Deploy-App }
        "2" { View-Apps }
        "3" { Delete-App }
        "4" { View-AppLogs }
        "5" { Ensure-LadeLogin }
        "6" { Write-Host-Cyan "ÍË³ö½Å±¾¡£ÔÙ¼û£¡"; break } # ÍË³öÑ­»·
        default { Write-Host-Red "ÎÞÐ§µÄÑ¡Ôñ£¬ÇëÊäÈë 1 µ½ 6 Ö®¼äµÄÊý×Ö¡£" }
    }
    Write-Host ""
    Read-Host "°´ Enter ¼ü¼ÌÐø..." | Out-Null # µÈ´ýÓÃ»§°´ Enter ¼ü¼ÌÐø
}

Write-Host-Blue "½Å±¾Ö´ÐÐÍê±Ï¡£"
