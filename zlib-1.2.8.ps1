$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "zlib-1.2.8.ps1"
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
## zlib 1.2.8
##
$zlib_url  = "http://sourceforge.net/projects/libpng/files/zlib/1.2.8/zlib-1.2.8.tar.xz/download"
$zlib_arc  = "$arc_path\zlib-1.2.8.tar.xz"
$zlib_arc2 = [System.IO.Path]::GetFileNameWithoutExtension($zlib_arc)
$zlib_nam  = [System.IO.Path]::GetFileNameWithoutExtension($zlib_arc2)
$zlib_dir  = "$root_path\$zlib_nam"
$zlib_nmakefile = "win32/Makefile.msc"
$zlib_nmakeopt  = 'zlib.lib LOC="-DASMV -DASMINF" OBJA="inffas32.obj match686.obj"'

DownloadFile $zlib_url $zlib_arc

LogBegin "Extracting $zlib_arc"
rmdir -recurse $zlib_dir >$null 2>&1
_7za x -y $zlib_arc
_7za x -y $zlib_arc2
del $zlib_arc2
LogEnd

pushd $zlib_dir
LogBegin "Building zlib(win32)"
Push-EnvironmentBlock
cmd /c "`"${Env:VS110COMNTOOLS}vsvars32.bat`" && set" | .{ process {
    if ($_ -match '^([^=]+)=(.*)') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}}
Invoke-Expression -Command "nmake.exe -f $zlib_nmakefile $zlib_nmakeopt >> $script_log 2>&1"
del *.obj, *.res, *.exp, *.exe, *.manifest
Pop-EnvironmentBlock
LogEnd
popd # $zlib_dir

LogEnd # "** $script_name **"
