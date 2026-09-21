param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Normal", "Eco")]
    [string]$Mode,

    [Parameter(Mandatory=$true)]
    [int]$Duration
)

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$adb = "C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe"

$package = "com.ecolearn.ecolearn_app"

$intervalSeconds = 1

# ============================================================
# SCREEN COORDINATES
# YOU MUST MODIFY THESE AFTER CHECKING YOUR PHONE
# ============================================================

# Lessons bottom navigation
$lessonsNavX = 410
$lessonsNavY = 2274

# First lesson
$lessonX = 663
$lessonY = 574

# First chapter
$chapterX = 785
$chapterY = 447

# Video/material
$videoX = 596
$videoY = 716

# Video PLAY button
$playX = 551
$playY = 1183

# Back button
$backX = 77
$backY = 198

# ============================================================
# OUTPUT
# ============================================================

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"

$outputDir =
    Join-Path $PSScriptRoot "automated_results"

if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$csvPath =
    Join-Path $outputDir "VideoCPU_${Mode}_${timestamp}.csv"

# ============================================================
# HELPER FUNCTION
# ============================================================

function Tap-Screen {
    param(
        [int]$X,
        [int]$Y,
        [int]$Wait = 2
    )

    Write-Host "Tap: X=$X Y=$Y"

    & $adb shell input tap $X $Y

    Start-Sleep -Seconds $Wait
}

# ============================================================
# CHECK ADB
# ============================================================

Write-Host ""
Write-Host "============================================"
Write-Host " EcoLearn Automated Video Test"
Write-Host "============================================"
Write-Host "Mode     : $Mode"
Write-Host "Duration : $Duration seconds"
Write-Host "============================================"
Write-Host ""

& $adb get-state 2>$null | Out-Null

if ($LASTEXITCODE -ne 0) {

    Write-Host "ERROR: Android device not detected."
    Write-Host ""
    Write-Host "Run:"
    Write-Host "adb devices"

    exit 1
}

Write-Host "ADB device detected."

# ============================================================
# CLOSE ECOLEARN
# ============================================================

Write-Host ""
Write-Host "Closing EcoLearn..."

& $adb shell am force-stop $package

Start-Sleep -Seconds 2

# ============================================================
# START ECOLEARN
# ============================================================

Write-Host "Starting EcoLearn..."

& $adb shell monkey `
    -p $package `
    -c android.intent.category.LAUNCHER `
    1 | Out-Null

Start-Sleep -Seconds 5

# ============================================================
# NAVIGATE TO LESSONS
# ============================================================

Write-Host ""
Write-Host "Opening Lessons..."

Tap-Screen `
    -X $lessonsNavX `
    -Y $lessonsNavY `
    -Wait 3

# ============================================================
# OPEN LESSON
# ============================================================

Write-Host ""
Write-Host "Opening lesson..."

Tap-Screen `
    -X $lessonX `
    -Y $lessonY `
    -Wait 3

# ============================================================
# OPEN CHAPTER
# ============================================================

Write-Host ""
Write-Host "Opening chapter..."

Tap-Screen `
    -X $chapterX `
    -Y $chapterY `
    -Wait 3

# ============================================================
# OPEN VIDEO
# ============================================================

Write-Host ""
Write-Host "Opening video..."

Tap-Screen `
    -X $videoX `
    -Y $videoY `
    -Wait 5

# ============================================================
# ECO MODE PLAY
# ============================================================

if ($Mode -eq "Eco") {

    Write-Host ""
    Write-Host "Eco Mode detected."
    Write-Host "Starting video manually..."

    Tap-Screen `
        -X $playX `
        -Y $playY `
        -Wait 2
}
else {

    Write-Host ""
    Write-Host "Normal Mode."
    Write-Host "Video should auto-play."
}

# ============================================================
# FIND APP PID
# ============================================================

$pidText =
    (& $adb shell pidof $package 2>$null) -join " "

$pidText = $pidText.Trim()

if ([string]::IsNullOrWhiteSpace($pidText)) {

    Write-Host ""
    Write-Host "ERROR: EcoLearn process not found."
    exit 1
}

$appPid =
    ($pidText -split "\s+")[0]

Write-Host ""
Write-Host "EcoLearn PID: $appPid"

# ============================================================
# WAIT BEFORE MEASUREMENT
# ============================================================

Write-Host ""
Write-Host "Starting CPU measurement in 3 seconds..."

Start-Sleep -Seconds 3

# ============================================================
# CPU MEASUREMENT
# ============================================================

$results = @()

for ($i = 1; $i -le $Duration; $i++) {

    $sampleTime =
        Get-Date -Format "HH:mm:ss"

    $topOutput =
        (& $adb shell top -b -n 1 -p $appPid 2>$null) -join "`n"

    $lines =
        $topOutput -split "`r?`n"

    $cpu = $null

    foreach ($line in $lines) {

        if ($line -match "^\s*$appPid\s+") {

            $parts = $line -split "\s+"

            # Your phone's top format:
            # PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ ARGS
            #
            # CPU is index 9

            if ($parts.Count -gt 8) {

                $candidate = $parts[8].Trim()

                if ($candidate -match '^\d+(\.\d+)?$') {

                    $cpu = [double]$candidate
                    break
                }
            }
        }
    }

    # --------------------------------------------------------
    # Save reading
    # --------------------------------------------------------

    if ($null -eq $cpu) {

        Write-Host `
            "$sampleTime Sample $i/$Duration : CPU not detected"

    }
    else {

        Write-Host `
            "$sampleTime Sample $i/$Duration : CPU = $cpu %"

        $results +=
            [PSCustomObject]@{

                Mode =
                    $Mode

                Sample =
                    $i

                Time =
                    $sampleTime

                CPU_Percent =
                    $cpu
            }
    }

    Start-Sleep `
        -Seconds $intervalSeconds
}

# ============================================================
# PRESS BACK AFTER VIDEO TEST
# ============================================================

Write-Host ""
Write-Host "Video test completed."
Write-Host "Pressing Back button..."

Tap-Screen `
    -X $backX `
    -Y $backY `
    -Wait 2

# ============================================================
# SAVE CSV
# ============================================================

$results |
    Export-Csv `
        -Path $csvPath `
        -NoTypeInformation

# ============================================================
# SUMMARY
# ============================================================

Write-Host ""
Write-Host "============================================"
Write-Host " TEST COMPLETED"
Write-Host "============================================"

if ($results.Count -gt 0) {

    $average =
        ($results |
            Measure-Object `
                -Property CPU_Percent `
                -Average).Average

    $minimum =
        ($results |
            Measure-Object `
                -Property CPU_Percent `
                -Minimum).Minimum

    $maximum =
        ($results |
            Measure-Object `
                -Property CPU_Percent `
                -Maximum).Maximum

    Write-Host ""
    Write-Host "Mode          : $Mode"
    Write-Host "Samples       : $($results.Count)"
    Write-Host ("Average CPU   : {0:N2} %" -f $average)
    Write-Host ("Minimum CPU   : {0:N2} %" -f $minimum)
    Write-Host ("Maximum CPU   : {0:N2} %" -f $maximum)
}
else {
    Write-Host ""
    Write-Host "No CPU samples were collected."
}

Write-Host ""
Write-Host "CSV:"
Write-Host $csvPath
Write-Host ""