<#
    file_manage.ps1 - deploy flow files from script\ into their runtime locations.
    Native Windows PowerShell equivalent of file_manage.sh (use when bash is not
    available). Safe to run from any working directory.

    Usage:  powershell -ExecutionPolicy Bypass -File script\file_manage.ps1
#>

$ErrorActionPreference = 'Stop'

# Resolve the directory this script lives in (verify\script) and the root (verify\).
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$rootDir   = (Resolve-Path (Join-Path $scriptDir '..')).Path

function Copy-Item-Deploy {
    param([string]$Src, [string]$Dst)
    if (-not (Test-Path $Src)) {
        Write-Error "source not found: $Src"
    }
    $dstParent = Split-Path -Parent $Dst
    if (-not (Test-Path $dstParent)) {
        New-Item -ItemType Directory -Force -Path $dstParent | Out-Null
    }
    Copy-Item -Path $Src -Destination $Dst -Recurse -Force
    Write-Host "  $Src -> $Dst"
}

Write-Host "Deploying flow files (root: $rootDir)"
Copy-Item-Deploy (Join-Path $scriptDir 'utils')                    (Join-Path $rootDir 'utils')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\wsim')               (Join-Path $rootDir 'sim\wsim')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\project_name')       (Join-Path $rootDir 'sim\project_name')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\testjson2lst.py')    (Join-Path $rootDir 'tb_top\scripts\testjson2lst.py')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\Makefile')           (Join-Path $rootDir 'tb_top\scripts\Makefile')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\Makefile.rtdbg.tcl') (Join-Path $rootDir 'tb_top\scripts\Makefile.rtdbg.tcl')
Copy-Item-Deploy (Join-Path $scriptDir 'sflow\Makefile.run.tcl')   (Join-Path $rootDir 'tb_top\scripts\Makefile.run.tcl')
Write-Host "Done."
