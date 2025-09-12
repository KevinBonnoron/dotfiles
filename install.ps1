$dotfilesDir = "$HOME\dotfiles"

$source = "$dotfilesDir\.config\nvim"
$destination = "$env:LOCALAPPDATA\nvim"

if (Test-Path $destination) {
    Remove-Item $destination -Recurse -Force
    Write-Output "Old folder removed: $destination"
}

New-Item -ItemType SymbolicLink -Path $destination -Target $source
Write-Output "Symbolic link created: $destination → $source"
