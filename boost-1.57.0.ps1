$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "boost-1.57.0.ps1"
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
## boost 1.57.0
##
$boost_url = "http://sourceforge.net/projects/boost/files/boost/1.57.0/boost_1_57_0.7z"
$boost_arc = "$arc_path\$(GetNameFromUrl $boost_url)"
$boost_nam = [System.IO.Path]::GetFileNameWithoutExtension($boost_arc)
$boost_dir = "$root_path\$boost_nam"
$boost_bjam_opt        = "-d 0 -j $(GetNumberOfCores) link=static runtime-link=static toolset=msvc-12.0"
$boost_win32_lib       = "$boost_dir\lib\win32"
$boost_x64_lib         = "$boost_dir\lib\x64"
$boost_win32_build_dir = "$boost_dir\bin.win32"
$boost_x64_build_dir   = "$boost_dir\bin.x64"
$boost_win32_stage     = "$boost_dir\stage_win32"
$boost_x64_stage       = "$boost_dir\stage_x64"
$boost_win32_bjam_opt  = "$boost_bjam_opt --build-dir=$boost_win32_build_dir --stagedir=$boost_win32_stage"
$boost_x64_bjam_opt    = "$boost_bjam_opt --build-dir=$boost_x64_build_dir --stagedir=$boost_x64_stage address-model=64"

DownloadFile $boost_url $boost_arc

LogBegin "Extracting $boost_arc"
rmdir -recurse $boost_dir >$null 2>&1
_7za x -y $boost_arc
LogEnd

LogBegin "Bootstrap boost"
pushd $boost_dir
if(-not (Test-Path -path .\b2.exe)) {
    .\bootstrap >> $script_log
}
.\b2 --clean toolset=msvc-12.0 > $null
LogEnd

LogBegin "Building boost(win32)"
Invoke-Expression -Command ".\bjam $boost_win32_bjam_opt stage >> $script_log"
mkdir -force $boost_win32_lib >$null 2>&1
move -force $boost_win32_stage\lib\*.* $boost_win32_lib
rmdir -recurse $boost_win32_build_dir >$null 2>&1
LogEnd

LogBegin "Building boost(x64)"
Invoke-Expression -Command ".\bjam $boost_x64_bjam_opt stage >> $script_log"
mkdir -force $boost_x64_lib >$null 2>&1
move -force $boost_x64_stage\lib\*.* $boost_x64_lib
rmdir -recurse $boost_x64_build_dir >$null 2>&1
LogEnd

popd # $boost_dir

LogEnd # "** $script_name **"
