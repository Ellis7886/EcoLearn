# ============================================================
# EcoLearn - repeated Eco vs Normal measurement (video scenario)
#
# Measures for EVERY run:
#   - CPU %            (adb shell top, every second)
#   - Memory PSS (KB)  (adb shell dumpsys meminfo, every 5 seconds)
#   - Network bytes and execution times come from the app itself
#     (performance_log_v2.csv, copied to the PC at the end)
#
# Example (10 runs of 60 seconds on the real phone):
#   .\ecolearn_measure.ps1 -Mode Eco -Runs 10 -Duration 60 -Device Phone
#
# BEFORE RUNNING
#   1. Install a PROFILE or RELEASE build:  flutter run --profile
#   2. In the app, switch Eco Mode ON or OFF to match -Mode.
#   3. Check the screen coordinates below for your device.
#   4. Same conditions for both modes: same Wi-Fi, battery > 50 %,
#      phone not charging if possible, other apps closed.
# ============================================================

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Normal", "Eco")]
    [string]$Mode,

    # Seconds of measurement per run
    [int]$Duration = 60,

    # Number of measured runs (10-30 recommended)
    [int]$Runs = 10,

    [ValidateSet("Phone", "Emulator")]
    [string]$Device = "Phone",

    # One extra run first that is NOT recorded. In Eco Mode this
    # downloads the optimised video once, so the measured runs show
    # the normal Eco behaviour (offline copy). Use -NoWarmUp to
    # measure the first download instead.
    [switch]$NoWarmUp,

    # Screen brightness used during the test (0-255)
    [int]$Brightness = 128
)

$ErrorActionPreference = "Stop"

# ============================================================
# CONFIGURATION
# ============================================================

$adb = "C:\Users\user\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$package = "com.ecolearn.ecolearn_app"
$memoryEverySeconds = 5

# ============================================================
# SCREEN COORDINATES (copied from your two scripts)
# ============================================================

if ($Device -eq "Phone") {
    $lessonsNavX = 410; $lessonsNavY = 2274
    $lessonX     = 663; $lessonY     = 574
    $chapterX    = 785; $chapterY    = 447
    $videoX      = 596; $videoY      = 716
    $playX       = 551; $playY       = 1183
    $backX       = 77;  $backY       = 198
} else {
    $lessonsNavX = 418; $lessonsNavY = 2253
    $lessonX     = 504; $lessonY     = 444
    $chapterX    = 417; $chapterY    = 406
    $videoX      = 433; $videoY      = 646
    $playX       = 542; $playY       = 1159
    $backX       = 68;  $backY       = 193
}

# ============================================================
# OUTPUT
# ============================================================

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputDir = Join-Path $PSScriptRoot "automated_results"
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir | Out-Null
}

$samplesCsv = Join-Path $outputDir "Samples_${Mode}_${Device}_${timestamp}.csv"
$summaryCsv = Join-Path $outputDir "Summary_${Mode}_${Device}_${timestamp}.csv"
$appLogCsv  = Join-Path $outputDir "AppLog_${Mode}_${Device}_${timestamp}.csv"

# ============================================================
# HELPERS
# ============================================================

function Tap-Screen {
    param([int]$X, [int]$Y, [int]$Wait = 2)
    & $adb shell input tap $X $Y
    Start-Sleep -Seconds $Wait
}

function Get-CpuPercent {
    param([string]$AppPid)

    $lines = (& $adb shell top -b -n 1 -p $AppPid 2>$null) -split "`r?`n"

    foreach ($line in $lines) {
        if ($line -match "^\s*$AppPid\s+") {
            # PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ ARGS
            $parts = ($line.Trim()) -split "\s+"
            if ($parts.Count -gt 8 -and $parts[8] -match '^\d+(\.\d+)?$') {
                return [double]$parts[8]
            }
        }
    }
    return $null
}

function Get-MemoryPssKb {
    $text = (& $adb shell dumpsys meminfo $package 2>$null) -join "`n"

    # Android 10+ : "TOTAL PSS:   123456"
    if ($text -match "TOTAL PSS:\s+(\d+)") {
        return [int]$Matches[1]
    }
    # Older Android : "        TOTAL   123456 ..."
    if ($text -match "(?m)^\s*TOTAL\s+(\d+)") {
        return [int]$Matches[1]
    }
    return $null
}

function Open-VideoScenario {
    # Start the app fresh and open the test video
    & $adb shell am force-stop $package
    Start-Sleep -Seconds 2

    & $adb shell monkey -p $package -c android.intent.category.LAUNCHER 1 | Out-Null
    Start-Sleep -Seconds 5

    Tap-Screen -X $lessonsNavX -Y $lessonsNavY -Wait 3
    Tap-Screen -X $lessonX -Y $lessonY -Wait 3
    Tap-Screen -X $chapterX -Y $chapterY -Wait 3

    # Eco Mode: the first open may download the file, so wait longer
    Tap-Screen -X $videoX -Y $videoY -Wait 8

    if ($Mode -eq "Eco") {
        # Eco Mode has no autoplay -> press play
        Tap-Screen -X $playX -Y $playY -Wait 2
    }
}

# ============================================================
# CHECK DEVICE
# ============================================================

& $adb get-state 2>$null | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Android device not detected. Run: adb devices"
    exit 1
}

Write-Host ""
Write-Host "============================================"
Write-Host " EcoLearn measurement"
Write-Host " Mode: $Mode | Device: $Device | Runs: $Runs | Duration: $Duration s"
Write-Host "============================================"
Write-Host ""
Write-Host "Is Eco Mode switched $(if ($Mode -eq 'Eco') {'ON'} else {'OFF'}) in the app?"
Read-Host "Press Enter to start"

# Fixed brightness for every run (restored at the end)
$oldBrightnessMode = (& $adb shell settings get system screen_brightness_mode).Trim()
$oldBrightness     = (& $adb shell settings get system screen_brightness).Trim()
& $adb shell settings put system screen_brightness_mode 0
& $adb shell settings put system screen_brightness $Brightness

# Start each test with an empty app log on the phone
$phoneLog = "/sdcard/Android/data/$package/files/performance_log_v2.csv"
try { & $adb shell rm -f $phoneLog 2>$null | Out-Null } catch { }

$samples = New-Object System.Collections.Generic.List[object]
$summary = New-Object System.Collections.Generic.List[object]

try {
    # --------------------------------------------------------
    # WARM-UP (not recorded)
    # --------------------------------------------------------
    if (-not $NoWarmUp) {
        Write-Host "Warm-up run (not recorded)..."
        Open-VideoScenario
        Start-Sleep -Seconds 10
        Tap-Screen -X $backX -Y $backY -Wait 2
    }

    # --------------------------------------------------------
    # MEASURED RUNS
    # --------------------------------------------------------
    for ($run = 1; $run -le $Runs; $run++) {

        Write-Host ""
        Write-Host "---- Run $run / $Runs ----"

        Open-VideoScenario

        $appPid = ((& $adb shell pidof $package 2>$null) -join " ").Trim()
        if ([string]::IsNullOrWhiteSpace($appPid)) {
            Write-Host "ERROR: EcoLearn is not running. Run skipped."
            continue
        }
        $appPid = ($appPid -split "\s+")[0]

        Start-Sleep -Seconds 3

        $cpuValues = @()
        $memValues = @()

        for ($i = 1; $i -le $Duration; $i++) {
            $cpu = Get-CpuPercent -AppPid $appPid

            $mem = $null
            if (($i % $memoryEverySeconds) -eq 1) {
                $mem = Get-MemoryPssKb
            }

            if ($null -ne $cpu) { $cpuValues += $cpu }
            if ($null -ne $mem) { $memValues += $mem }

            $samples.Add([PSCustomObject]@{
                Mode        = $Mode
                Device      = $Device
                Run         = $run
                Second      = $i
                Time        = Get-Date -Format "HH:mm:ss"
                CPU_Percent = $cpu
                PSS_KB      = $mem
            })

            Start-Sleep -Seconds 1
        }

        # Leaving the video page makes the app log the
        # "Video Session" row (network bytes, time, memory)
        Tap-Screen -X $backX -Y $backY -Wait 2

        $avgCpu = if ($cpuValues.Count) { ($cpuValues | Measure-Object -Average).Average } else { $null }
        $maxCpu = if ($cpuValues.Count) { ($cpuValues | Measure-Object -Maximum).Maximum } else { $null }
        $avgMem = if ($memValues.Count) { ($memValues | Measure-Object -Average).Average } else { $null }
        $maxMem = if ($memValues.Count) { ($memValues | Measure-Object -Maximum).Maximum } else { $null }

        $summary.Add([PSCustomObject]@{
            Mode            = $Mode
            Device          = $Device
            Run             = $run
            CPU_Avg_Percent = $avgCpu
            CPU_Max_Percent = $maxCpu
            PSS_Avg_KB      = $avgMem
            PSS_Max_KB      = $maxMem
            CPU_Samples     = $cpuValues.Count
        })

        Write-Host ("Run {0}: CPU avg {1:N2} % | PSS avg {2:N0} KB" -f $run, $avgCpu, $avgMem)
    }
}
finally {
    # Restore brightness
    & $adb shell settings put system screen_brightness_mode $oldBrightnessMode
    & $adb shell settings put system screen_brightness $oldBrightness

    $samples | Export-Csv -Path $samplesCsv -NoTypeInformation
    $summary | Export-Csv -Path $summaryCsv -NoTypeInformation

    # Copy the app's own log (execution time, network bytes, memory)
    try {
        & $adb pull $phoneLog $appLogCsv 2>$null | Out-Null
    } catch {
        Write-Host "Could not copy the app log: $_"
    }
}

Write-Host ""
Write-Host "============================================"
Write-Host " DONE"
Write-Host "============================================"
Write-Host "Per-second samples : $samplesCsv"
Write-Host "Per-run summary    : $summaryCsv"
if (Test-Path $appLogCsv) {
    Write-Host "App log            : $appLogCsv"
} else {
    Write-Host "App log could not be copied. Copy it manually with:"
    Write-Host "  adb pull $phoneLog"
}
