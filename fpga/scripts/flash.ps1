# flash.ps1
#
# Programs the Colorlight 5A-75B (v8.0) FPGA over JTAG via a STM32F103
# Blue Pill running DirtyJTAG firmware. Writes to SRAM by default (temporary
# - lost on power-off), never to flash, unless -WriteFlash is passed explicitly.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\flash.ps1            # build\blink.bit -> SRAM
#   powershell -ExecutionPolicy Bypass -File scripts\flash.ps1 -Detect    # just detect the JTAG chain
#   powershell -ExecutionPolicy Bypass -File scripts\flash.ps1 -Bitstream build\other.bit

param(
    [string]$Cable = "dirtyJtag",
    [string]$Bitstream = "build\blink.bit",
    [switch]$Detect,
    [switch]$WriteFlash
)

$ErrorActionPreference = "Stop"
. "C:\oss-cad-suite\environment.ps1" | Out-Null

$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ($Detect) {
    Write-Host "==> Detecting JTAG chain (-c $Cable)"
    & openFPGALoader.exe -c $Cable --detect
    exit $LASTEXITCODE
}

$bitPath = Join-Path $root $Bitstream
if (-not (Test-Path $bitPath)) {
    Write-Error "Bitstream not found: $bitPath (run scripts\build.ps1 first)"
    exit 1
}

if ($WriteFlash) {
    Write-Host "==> Programming SPI FLASH (permanent) -c $Cable : $bitPath"
    & openFPGALoader.exe -c $Cable --write-flash $bitPath
} else {
    Write-Host "==> Programming SRAM (temporary, lost on power-off) -c $Cable : $bitPath"
    & openFPGALoader.exe -c $Cable $bitPath
}

exit $LASTEXITCODE
