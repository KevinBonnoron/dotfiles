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

function Install-ClaudeSkills {
    Write-Info 'Installing Claude Code skills...'

    $skillsSource = Join-Path $DotfilesDir 'skills'
    $skillsDest = Join-Path $HOME '.claude\skills'

    if (-not (Test-Path $skillsSource)) {
        Write-Info 'No skills directory found in dotfiles, skipping.'
        return
    }

    New-Item -ItemType Directory -Force -Path $skillsDest | Out-Null

    Get-ChildItem -Path $skillsSource -Directory | ForEach-Object {
        $skillName = $_.Name
        $dest = Join-Path $skillsDest $skillName

        if (Test-Path $dest) {
            $item = Get-Item $dest -Force
            if ($item.LinkType -eq 'Junction' -or $item.LinkType -eq 'SymbolicLink') {
                Write-Info ("Skill '$skillName' already linked")
                return
            }
            Write-Info ("Existing skill '$skillName' found. Backing up...")
            Rename-Item -Path $dest -NewName ($dest + '.bak')
        }

        try {
            New-Item -ItemType Junction -Path $dest -Target $_.FullName | Out-Null
            Write-Success ("Skill '$skillName' linked to $dest")
        } catch {
            Write-Output ("WARNING: Could not link skill '$skillName': $_")
        }
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

# Main script
function Main {
    Write-Output ('Installing dotfiles...')
    Write-Output ('Dotfiles directory: ' + $DotfilesDir)
    Write-Output ""

    Test-DotfilesDirectory
    Test-GitInstalled
    Install-GitConfig
    Install-ClaudeSkills
    Install-TernConfig

    Write-Output ""
    Write-Success ('Installation completed!')
}

Main
