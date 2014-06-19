##
$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "hatch-msysgit-1.9.4.ps1"
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

Function ExtractZip($fname) {
    $s = new-object -com shell.application
    $s.namespace("$pwd").Copyhere($s.namespace("$fname").items(),0x14)
}

Function GetNumberOfCores() {
    return (Get-WmiObject win32_processor).NumberOfCores
}

Function GetNumberOfLogicalProcessors() {
    return (Get-WmiObject win32_processor).NumberOfLogicalProcessors
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
## 7-Zip 9.20
##
$_7za_bin = "$bin_path\7za.exe"
$_7za_url = "http://sourceforge.net/projects/sevenzip/files/7-Zip/9.20/7za920.zip"
$_7za_arc = "$arc_path\$(GetNameFromUrl $_7za_url)"
$_7za_tmp = "$_7za_arc.tempd"

Function _7za() {
    if(-not (Test-Path -path $_7za_bin)) {
        DownloadFile $_7za_url $_7za_arc
        mkdir -force $_7za_tmp >$null 2>&1
        pushd $_7za_tmp
        ExtractZip $_7za_arc
        copy 7za.exe $_7za_bin
        popd
        rmdir -recurse $_7za_tmp >$null 2>&1
    }

    if(Test-Path -path $_7za_bin) {
        Invoke-Expression -Command "$_7za_bin $args >> $script_log"
    } else {
        echo "Can't invoke $_7za_bin"
        exit
    }
}


##
## Git-1.9.4-preview20140611
## https://github.com/msysgit/msysgit/releases/tag/Git-1.9.4-preview20140611
##
$msysgit_dir = "$bin_path\msysgit"
$msysgit_bin = "$msysgit_dir\cmd\git.exe"
$msysgit_url = "https://github.com/msysgit/msysgit/releases/download/Git-1.9.4-preview20140611/PortableGit-1.9.4-preview20140611.7z"
$msysgit_arc = "$arc_path\$(GetNameFromUrl $msysgit_url)"

Function MsysGit() {
    if(-not (Test-Path -path $msysgit_bin)) {
        DownloadFile $msysgit_url $msysgit_arc
        rmdir -recurse $msysgit_dir >$null 2>&1
        mkdir -force $msysgit_dir >$null 2>&1
        pushd $msysgit_dir
        _7za x -y $msysgit_arc
        popd
    }

    if(Test-Path -path $msysgit_bin) {
        Invoke-Expression -Command "$msysgit_bin $args >> $script_log"
    } else {
        echo "Can't invoke $msysgit_bin"
        exit
    }
}


##
MsysGit --version

LogEnd # "** $script_name **"
