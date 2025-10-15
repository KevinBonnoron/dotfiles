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

# Main script
function Main {
    Write-Output ('Installing dotfiles...')
    Write-Output ('Dotfiles directory: ' + $DotfilesDir)
    Write-Output ""

    Test-DotfilesDirectory
    Test-GitInstalled
    Install-GitConfig

    Write-Output ""
    Write-Success ('Installation completed!')
}

Main
