$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "install-speedcrunch-0.10.1.ps1"
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
## SpeedCrunch-0.10.1
##
$speedcrunch_url  = "http://speedcrunch.googlecode.com/files/SpeedCrunch-0.10.1.exe"
$speedcrunch_arc  = "$arc_path\$(GetNameFromUrl $speedcrunch_url)"

DownloadFile $speedcrunch_url $speedcrunch_arc

LogBegin "Installing $speedcrunch_arc"
## Setup Command Line Parameters
## http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline
cmd /c "start /wait $speedcrunch_arc /SP- /VERYSILENT /NORESTART"
LogEnd

LogEnd # "** $script_name **"
