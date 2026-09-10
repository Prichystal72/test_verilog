# sim.ps1
#
# Compile and run the blink testbench with Icarus Verilog.
# No FPGA hardware required.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File scripts\sim.ps1
#   (add -Wave to also open the result in GTKWave)

param(
    [switch]$Wave
)

$ErrorActionPreference = "Stop"
. "C:\oss-cad-suite\environment.ps1" | Out-Null

$root    = Split-Path -Parent $PSScriptRoot
$build   = Join-Path $root "build"
New-Item -ItemType Directory -Force -Path $build | Out-Null

$out = Join-Path $build "blink_tb.vvp"

Write-Host "==> Compiling with iverilog"
& iverilog -g2012 -o $out `
    (Join-Path $root "rtl\blink.v") `
    (Join-Path $root "tb\blink_tb.v")

Write-Host "==> Running simulation"
Push-Location $build
try {
    & vvp $out
} finally {
    Pop-Location
}

if ($Wave) {
    $vcd = Join-Path $build "blink_tb.vcd"
    Write-Host "==> Opening GTKWave"
    & gtkwave $vcd
}
