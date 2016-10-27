<# :
@echo off
copy/b "%~f0" "%temp%\%~n0.ps1" >nul
powershell -Version 2 -ExecutionPolicy bypass -noprofile "%temp%\%~n0.ps1" "%cd% " "%~1"
del "%temp%\%~n0.ps1"
pause
exit /b
#>
param([string]$cwd='.', [string]$dll)

function main {
    "Chrome 'developer mode extensions' warning disabler v1.0.7.20160919`n"
    $pathsDone = @{}
    if ($dll -and (gi -literal $dll)) {
        doPatch "DRAG'n'DROPPED" ((gi -literal $dll).directoryName + '\')
        exit
    }
    doPatch CURRENT ((gi -literal $cwd).fullName + '\')
    ('HKLM', 'HKCU') | %{ $hive = $_
        ('', '\Wow6432Node') | %{
            $key = "${hive}:\SOFTWARE$_\Google\Update\Clients"
            gci -ea silentlycontinue $key -r | gp | ?{ $_.CommandLine } | %{
                $path = $_.CommandLine -replace '"(.+?\\\d+\.\d+\.\d+\.\d+\\).+', '$1'
                doPatch REGISTRY $path
            }
        }
    }
}

function doPatch([string]$pathLabel, [string]$path) {
    if ($pathsDone[$path.toLower()]) { return }

    $dll = $path + "chrome.dll"
    if (!(test-path -literal $dll)) {
        return
    }
    "======================="
    "$pathLabel PATH $((gi -literal $dll).DirectoryName)"

    "`tREADING Chrome.dll..."
    $bytes = [IO.File]::ReadAllBytes($dll)

    # process PE headers
    $BC = [BitConverter]
    $coff = $BC::ToUInt32($bytes,0x3C) + 4
    $is64 = $BC::ToUInt16($bytes,$coff) -eq 0x8664
    $opthdr = $coff+20
    $codesize = $BC::ToUInt32($bytes,$opthdr+4)
    $imagebase32 = $BC::ToUInt32($bytes,$opthdr+28)

    # patch the flag in data section
    $data = $BC::ToString($bytes,$codesize)
    $flag = "ExtensionDeveloperModeWarning"
    $stroffs = $data.IndexOf($BC::ToString($flag[1..99]))/3 - 1
    if ($stroffs -lt 0) {
        write-host -f red "`t$flag not found"
        return
    }
    $stroffs += $codesize
    if ($bytes[$stroffs] -eq 0) {
        write-host -f green "`tALREADY PATCHED"
        return
    }

    $exe = join-path (split-path $path) chrome.exe
    $EA = $ErrorActionPreference
    $ErrorActionPreference = 'silentlyContinue'
    while ((get-process chrome -module | ?{ $_.FileName -eq $exe })) {
        forEach ($timeout in 15..0) {
            write-host -n -b yellow -f black `
                "`rChrome is running and will be terminated in $timeout sec. "
            write-host -n -b yellow -f darkyellow "Press ENTER to do it now. "
            if ([console]::KeyAvailable) {
                $key = $Host.UI.RawUI.ReadKey("AllowCtrlC,IncludeKeyDown,NoEcho")
                if ($key.virtualKeyCode -eq 13) { break }
                if ($key.virtualKeyCode -eq 27) { write-host; exit }
            }
            sleep 1
        }
        write-host
        get-process chrome | ?{
            $_.MainWindowHandle.toInt64() -and ($_ | gps -file).FileName -eq $exe
        } | %{
            "`tTrying to exit gracefully..."
            if ($_.CloseMainWindow()) {
                sleep 1
            }
        }
        $killLabelShown = 0
        get-process chrome | ?{
            ($_ | gps -file | select -expand FileName) -eq $exe
        } | %{
            if (!$killLabelShown++) {
                "`tTerminating background chrome processes..."
            }
            stop-process $_ -force
        }
        sleep -milliseconds 200
    }
    $ErrorActionPreference = $EA

    $bytes[$stroffs] = 0
    "`tPATCHED $flag flag"

    # patch the channel restriction code for stable/beta
    $code = $BC::ToString($bytes,0,$codesize)
    $codepattern = "83-F8-03-7D-.{1,100}"
    $chanpos = 0
    try {
        if ($is64) {
            $pos = 0
            $rx = [regex] "$codepattern-48-8D"
            do {
                $m = $rx.match($code,$pos)
                if (!$m.success) { break }
                $chanpos = $m.index/3 + 2
                $pos = $m.index + $m.length + 1
                $offs = $BC::ToUInt32($bytes,$pos/3+1)
                $diff = $pos/3+5+$offs - $stroffs
            } until ($diff -ge 0 -and $diff -le 4096 -and $diff % 256 -eq 0)
            if (!$m.success) {
                $rx = [regex]'84-C0.{18,48}83-F8-(03)-7D-.{30,60}84-C0'
                $m = $rx.matches($code)
                if ($m.count -ne 1) { throw }
                $chanpos = $m[0].groups[1].index/3
            }
        } else {
            $flagOffs = [uint32]$stroffs + [uint32]$imagebase32
            $flagOffsStr = $BC::ToString($BC::GetBytes($flagOffs))
            $variants = "($codepattern)-68-`$1-.{6}`$2",
                        '68-$1-.{6}$2.{300,500}E8.{12,32}(83-F8-03-7D)',
                        'E8.{12,32}(83-F8-03-7D).{300,500}68-$1-.{6}$2'
            forEach ($variant in $variants) {
                $pattern = $flagOffsStr -replace '^(..)-.{6}(..)', $variant
                "`tLooking for $pattern..."
                $m = [regex]::matches($code, $pattern)
                if ($m -and $m.count -eq 1) {
                    $chanpos = $m[0].groups[1].index/3 + 2
                    break
                }
            }
            if (!$chanpos) { throw }
        }
    } catch {
        write-host -f red "`tUnable to find the channel code, try updating me"
        write-host -f red "`thttp://stackoverflow.com/a/30361260"
        return
    }
    $bytes[$chanpos] = 9
    "`tPATCHED Chrome release channel restriction"

    "`tWriting to a temporary dll..."
    [IO.File]::WriteAllBytes("$dll.new",$bytes)

    "`tBacking up the original dll..."
    move -literal $dll "$dll.bak" -force

    "`tRenaming the temporary dll as the original dll..."
    move -literal "$dll.new" $dll -force

    $pathsDone[$path.toLower()] = $true
    "DONE.`n"
}

main
