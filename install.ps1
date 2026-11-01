param(
    [string]$DotfilesDir = "$HOME\dotfiles"
)

# Utility functions
function Write-Info {
    param([string]$Message)
    Write-Output ('INFO: ' + $Message)
}

function Write-Success {
    param([string]$Message)
    Write-Output ('SUCCESS: ' + $Message)
}

function Test-DotfilesDirectory {
    if (-not (Test-Path $DotfilesDir)) {
        Write-Error ('The dotfiles directory does not exist: ' + $DotfilesDir)
        exit 1
    }
}

function Test-GitInstalled {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Error ('Git is not installed.')
        exit 1
    }
}

function Install-GitConfig {
    Write-Info ('Installing Git configuration...')

    $gitConfigSource = ($DotfilesDir + '\.gitconfig').Replace('\', '/')
    $gitConfigDest = ($HOME + '\.gitconfig').Replace('\', '/')

    if (Test-Path $gitConfigDest) {
        $existingConfig = Get-Content $gitConfigDest -Raw

        if ($existingConfig -match [regex]::Escape("path = $gitConfigSource")) {
            Write-Info ('Include already present in ' + $gitConfigDest)
        } else {
            Write-Info ('Git configuration detected. Adding include...')

            $includeLines = @()
            $includeLines += ""
            $includeLines += '[include]'
            $includeLines += ('    path = ' + $gitConfigSource)
            $includeLines += ""
            $includeSection = $includeLines -join [Environment]::NewLine

            $newConfig = $includeSection + $existingConfig
            Set-Content -Path $gitConfigDest -Value $newConfig
            Write-Success ('Git include section added to ' + $gitConfigDest)
        }
    } else {
        Write-Info ('No Git configuration found. Creating a new .gitconfig...')

        $lines = @()
        $lines += '[include]'
        $lines += ('    path = ' + $gitConfigSource)

        Set-Content -Path $gitConfigDest -Value $lines
        Write-Success ('.gitconfig file created at ' + $gitConfigDest)
    }
}

function Install-TernConfig {
    Write-Info ('Installing Tern configuration...')

    $ternConfigDir = if ($env:TERN_CONFIG_DIR) { $env:TERN_CONFIG_DIR } else { Join-Path $env:APPDATA 'Tern' }
    $ternConfigDest = Join-Path $ternConfigDir 'settings.json'
    $ternConfigSource = Join-Path $DotfilesDir 'tern\settings.json'
    $backup = $ternConfigDest + '.bak'

    New-Item -ItemType Directory -Path $ternConfigDir -Force -ErrorAction Stop | Out-Null
    $existing = Get-Item -LiteralPath $ternConfigDest -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType) {
        Write-Info ('Link already exists at ' + $ternConfigDest)
        return
    }
    if ($existing) {
        if (Get-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue) {
            throw ('Backup already exists at ' + $backup + '; leaving Tern configuration unchanged')
        }
        Move-Item -LiteralPath $ternConfigDest -Destination $backup -ErrorAction Stop
        Write-Info ('Existing Tern settings backed up to ' + $backup)
    }
    New-Item -ItemType SymbolicLink -Path $ternConfigDest -Target $ternConfigSource -ErrorAction Stop | Out-Null
    Write-Success ('Tern config symlinked to ' + $ternConfigDest)
}

function Install-ZedConfig {
    Write-Info ('Installing Zed configuration...')

    # Whole directory, so files Zed rewrites or creates stay in the repository.
    $zedConfigDest = Join-Path $env:APPDATA 'Zed'
    $zedConfigSource = Join-Path $DotfilesDir 'zed'
    $backup = $zedConfigDest + '.bak'

    $existing = Get-Item -LiteralPath $zedConfigDest -Force -ErrorAction SilentlyContinue
    if ($existing -and $existing.LinkType) {
        Write-Info ('Link already exists at ' + $zedConfigDest)
        return
    }
    if ($existing) {
        if (Get-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue) {
            throw ('Backup already exists at ' + $backup + '; leaving Zed configuration unchanged')
        }
        Move-Item -LiteralPath $zedConfigDest -Destination $backup -ErrorAction Stop
        Write-Info ('Existing Zed configuration backed up to ' + $backup)
    }
    New-Item -ItemType SymbolicLink -Path $zedConfigDest -Target $zedConfigSource -ErrorAction Stop | Out-Null
    Write-Success ('Zed config symlinked to ' + $zedConfigDest)
}

# Returns the directory of the default Zen profile, or $null if Zen never ran.
function Get-ZenProfileDir {
    $zenDir = Join-Path $env:APPDATA 'zen'
    $profilesIni = Join-Path $zenDir 'profiles.ini'
    if (-not (Test-Path -LiteralPath $profilesIni)) {
        return $null
    }

    # The profile bound to the install ([Install*] Default=) wins over Default=1.
    $section = ''
    $installDefault = $null
    $defaultProfile = $null
    $path = $null
    $isDefault = $false
    foreach ($line in Get-Content -LiteralPath $profilesIni) {
        if ($line -match '^\[(.+)\]$') {
            $section = $Matches[1]
            $path = $null
            $isDefault = $false
            continue
        }
        if ($line -notmatch '^([^=]+)=(.*)$') {
            continue
        }
        $key = $Matches[1]
        $value = $Matches[2]
        if ($section -like 'Install*') {
            if ($key -eq 'Default' -and -not $installDefault) { $installDefault = $value }
        } elseif ($section -like 'Profile*') {
            if ($key -eq 'Path') { $path = $value }
            if ($key -eq 'Default' -and $value -eq '1') { $isDefault = $true }
            if ($path -and $isDefault -and -not $defaultProfile) { $defaultProfile = $path }
        }
    }

    $profilePath = if ($installDefault) { $installDefault } else { $defaultProfile }
    if (-not $profilePath) {
        return $null
    }
    if ([System.IO.Path]::IsPathRooted($profilePath)) {
        return $profilePath
    }
    return Join-Path $zenDir ($profilePath -replace '/', '\')
}

function Install-ZenConfig {
    Write-Info ('Installing Zen configuration...')

    $profileDir = Get-ZenProfileDir
    if (-not $profileDir -or -not (Test-Path -LiteralPath $profileDir)) {
        Write-Info ('No Zen profile found (start Zen once first), skipping.')
        return
    }

    foreach ($file in @('user.js', 'zen-keyboard-shortcuts.json')) {
        $source = Join-Path $DotfilesDir ('zen\' + $file)
        $dest = Join-Path $profileDir $file
        $backup = $dest + '.bak'

        $existing = Get-Item -LiteralPath $dest -Force -ErrorAction SilentlyContinue
        if ($existing -and $existing.LinkType) {
            Write-Info ('Link already exists at ' + $dest)
            continue
        }
        if ($existing) {
            if (Get-Item -LiteralPath $backup -Force -ErrorAction SilentlyContinue) {
                throw ('Backup already exists at ' + $backup + '; leaving Zen ' + $file + ' unchanged')
            }
            Move-Item -LiteralPath $dest -Destination $backup -ErrorAction Stop
            Write-Info ('Existing Zen ' + $file + ' backed up to ' + $backup)
        }
        New-Item -ItemType SymbolicLink -Path $dest -Target $source -ErrorAction Stop | Out-Null
        Write-Success ('Zen ' + $file + ' symlinked to ' + $dest)
    }
}

# Main script
function Main {
    Write-Output ('Installing dotfiles...')
    Write-Output ('Dotfiles directory: ' + $DotfilesDir)
    Write-Output ""

    Test-DotfilesDirectory
    Test-GitInstalled
    Install-GitConfig
    Install-TernConfig
    Install-ZedConfig
    Install-ZenConfig

    Write-Output ""
    Write-Success ('Installation completed!')
}

Main
