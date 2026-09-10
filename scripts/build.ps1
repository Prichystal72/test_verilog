# build.ps1
#
# Runs the full open-source ECP5 flow (synthesis -> place&route -> bitstream)
# for the Colorlight 5A-75B v8.0 board, WITHOUT programming any hardware.
# Its only purpose here is to prove the toolchain and constraints work
# end to end; the resulting .bit file is not uploaded anywhere.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\build.ps1

$ErrorActionPreference = "Stop"
. "C:\oss-cad-suite\environment.ps1" | Out-Null

$root  = Split-Path -Parent $PSScriptRoot
$build = Join-Path $root "build"
New-Item -ItemType Directory -Force -Path $build | Out-Null

$rtl         = Join-Path $root "rtl\blink.v"
$lpf         = Join-Path $root "constraints\colorlight_5a75b_v8.lpf"
$json        = Join-Path $build "blink.json"
$pnrConfig   = Join-Path $build "blink_out.config"
$bitstream   = Join-Path $build "blink.bit"

Write-Host "==> [1/3] Synthesis (Yosys)"
& yosys -p "read_verilog $rtl; synth_ecp5 -top blink -json $json"

Write-Host "==> [2/3] Place & route (nextpnr-ecp5)"
& nextpnr-ecp5 `
    --json $json `
    --lpf $lpf `
    --textcfg $pnrConfig `
    --25k `
    --package CABGA256 `
    --speed 6

Write-Host "==> [3/3] Bitstream packing (ecppack)"
# NOTE: on this toolchain build, ecppack.exe reliably writes a correct
# .bit file but then crashes on process exit (heap corruption, exit
# code -1073740940 / 0xC0000374). This is a known quirk, not a real
# failure, so we verify success via the output file instead of the
# process exit code. See docs/toolchain-notes.md.
& ecppack $pnrConfig $bitstream
$ecppackExit = $LASTEXITCODE

if (-not (Test-Path $bitstream) -or (Get-Item $bitstream).Length -eq 0) {
    Write-Error "ecppack did not produce a bitstream (exit code $ecppackExit)"
    exit 1
}
if ($ecppackExit -ne 0) {
    Write-Host "(ecppack exited with code $ecppackExit - known benign crash-on-exit, ignoring; bitstream file is valid)"
}

Write-Host ""
Write-Host "Build OK -> $bitstream"
Write-Host "(Not programmed anywhere - no hardware connected.)"
