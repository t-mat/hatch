$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "install-visual-studio-express-2012-for-windows-desktop.ps1"
$script_log  = "$log_path\$(Split-Path $script_name -Leaf).log"


##
## utils
##
Function Log([string] $str) {
    $s = "$(Get-Date -DisplayHint DateTime) $str"
    echo $s
    echo $s >> $script_log
}

$logStack = new-object System.Collections.Stack

Function LogBegin([string] $str) {
    $logStack.Push($str)
    Log " Start: $str"
}

Function LogEnd() {
    $str = $logStack.Pop()
    Log " End  : $str"
}

Function GetNameFromUrl($url) {
    return $url.Substring($url.LastIndexOf("/")+1)
}

Function DownloadFile($url, $fname) {
    if(-not (Test-Path -path $fname)) {
        LogBegin "Downloading $url -> $fname"
        (new-object System.Net.WebClient).DownloadFile($url, $fname)
        LogEnd
    }
}


##
##
##
mkdir $hatch_path -force >$null 2>&1
mkdir $bin_path   -force >$null 2>&1
mkdir $arc_path   -force >$null 2>&1
mkdir $log_path   -force >$null 2>&1

LogBegin "** $script_name **"


##
## Visual Studio Express 2012 for Windows Desktop
##
$vse2012wd_url = "http://go.microsoft.com/?linkid=9816758"
$vse2012wd_exe = "$arc_path\wdexpress_full.exe"
$vse2012wd_log = "$log_path\$(Split-Path $script_name -Leaf)-wdexpress_full.log"

DownloadFile $vse2012wd_url $vse2012wd_exe

LogBegin "Installing $vse2012wd_exe"
cmd /c "start /wait $vse2012wd_exe /Passive /NoRestart /Log $vse2012wd_log"
LogEnd

LogEnd # "** $script_name **"
