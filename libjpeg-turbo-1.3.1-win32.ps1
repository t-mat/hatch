$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "libjpeg-turbo-1.3.1-win32.ps1"
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
## CMake 2.8.12
##
$cmake_bin = "$bin_path\cmake.exe"
$cmake_url = "http://www.cmake.org/files/v2.8/cmake-2.8.12-win32-x86.zip"
$cmake_arc = "$arc_path\$(GetNameFromUrl $cmake_url)"
$cmake_dir = [System.IO.Path]::GetFileNameWithoutExtension($cmake_arc)
$cmake_tmp = "$cmake_arc.tempd"

Function cmake() {
    if(-not (Test-Path -path $cmake_bin)) {
        DownloadFile $cmake_url $cmake_arc
        mkdir -force $cmake_tmp >$null 2>&1
        pushd $cmake_tmp
        _7za x -y $cmake_arc
        copy $cmake_dir\bin\*.* $bin_path
        mkdir -force $bin_path\Modules >$null 2>&1
        copy -recurse -force $cmake_dir\share\cmake-2.8\Modules $bin_path\
        popd
        rmdir -recurse $cmake_tmp >$null 2>&1
    }

    if(Test-Path -path $cmake_bin) {
        Invoke-Expression -Command "$cmake_bin $args >> $script_log"
    } else {
        echo "Can't invoke $cmake_bin"
        exit
    }
}


##
## libjpeg-turbo 1.3.1
##
$target_url  = "http://sourceforge.net/projects/libjpeg-turbo/files/1.3.1/libjpeg-turbo-1.3.1.tar.gz/download"
$target_arc  = "$arc_path\libjpeg-turbo-1.3.1.tar.gz"
$target_arc2 = [System.IO.Path]::GetFileNameWithoutExtension($target_arc)
$target_nam  = [System.IO.Path]::GetFileNameWithoutExtension($target_arc2)
$target_dir = "$root_path\$($target_nam)-win32"
$target_cmake_gen_win32 = "Visual Studio 12"
$target_cmake_gen_x64 = "Visual Studio 12 Win64"
$target_msbuild_opt_win32 = "libjpeg-turbo.sln /nologo /m /p:Configuration=Release /p:Platform=Win32"
$target_msbuild_opt_x64 = "libjpeg-turbo.sln /nologo /m /p:Configuration=Release /p:Platform=x64"

DownloadFile $target_url $target_arc

LogBegin "Extracting $target_arc to $target_dir"
rmdir -recurse $target_dir >$null 2>&1
mkdir $target_dir >$null 2>&1
pushd $target_dir
_7za x -y $target_arc
_7za x -y $target_arc2
del $target_arc2
popd
LogEnd

## win32
pushd $target_dir"\"$target_nam

LogBegin "Building libjpeg-turbo (win32)"
$vars = [System.Environment]::GetEnvironmentVariables()
cmd /c "`"${Env:VS120COMNTOOLS}vsvars32.bat`" && set" | .{ process {
    if ($_ -match '^([^=]+)=(.*)') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}}
cmake -G "`"$target_cmake_gen_win32`""
Invoke-Expression -Command "msbuild.exe $target_msbuild_opt_win32 >> $script_log 2>&1"
foreach ($e in $vars.GetEnumerator()) {
  [System.Environment]::SetEnvironmentVariable($e.Key, $e.Value)
}
LogEnd

popd

LogEnd # "** $script_name **"
