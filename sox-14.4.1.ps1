$root_path   = "$pwd"
$hatch_path  = "$root_path\hatch"
$bin_path    = "$hatch_path\bin"
$arc_path    = "$hatch_path\arc"
$log_path    = "$hatch_path\log"
$script_name = "sox-14.4.1.ps1"
$script_log  = "$log_path\$(Split-Path $script_name -Leaf).log"
$output_dir  = "$root_path\$(Split-Path $script_name -Leaf)"


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
## SoX 14.4.1
##
mkdir $output_path -force >$null 2>&1
pushd $output_path

Function DownloadAndExtractTarX() {
    $target_url  = ???
    $target_arc  = ???
    $target_arc2 = [System.IO.Path]::GetFileNameWithoutExtension($target_arc)
    $target_tar  = $target_arc2
    $target_nam  = [System.IO.Path]::GetFileNameWithoutExtension($target_arc2)
    $target_dir  = $target_nam

    DownloadFile $target_url $target_arc
    del $target_tar
    rmdir -recurse $target_dir >$null 2>&1
    _7za x -y $target_arc
    _7za x -y $target_tar
    del $target_tar

    ディレクトリのリネーム
}

$target_url  = "http://sourceforge.net/projects/sox/files/sox/14.4.1/sox-14.4.1.tar.bz2/download"
$target_arc  = "$arc_path\sox-14.4.1.tar.bz2"
$target_arc2 = [System.IO.Path]::GetFileNameWithoutExtension($target_arc)
$target_nam  = [System.IO.Path]::GetFileNameWithoutExtension($target_arc2)
$target_dir  = "$root_path\$target_nam"

curl -L http://sourceforge.net/projects/sox/files/sox/14.4.1/sox-14.4.1.tar.bz2/download -o sox-14.4.1.tar.bz2
curl -L http://downloads.xiph.org/releases/flac/flac-1.2.1.tar.gz -o flac-1.2.1.tar.gz
curl -L http://sourceforge.net/projects/lame/files/lame/3.98.4/lame-3.98.4.tar.gz/download -o lame-3.98.4.tar.gz
curl -L http://sourceforge.net/projects/mad/files/libid3tag/0.15.1b/libid3tag-0.15.1b.tar.gz/download -o libid3tag-0.15.1b.tar.gz
curl -L http://sourceforge.net/projects/mad/files/libmad/0.15.1b/libmad-0.15.1b.tar.gz/download -o libmad-0.15.1b.tar.gz
curl -L http://downloads.xiph.org/releases/ogg/libogg-1.2.2.tar.xz -o libogg-1.2.2.tar.xz
curl -L http://sourceforge.net/projects/libpng/files/libpng15/older-releases/1.5.1/libpng-1.5.1.tar.xz/download -o libpng-1.5.1.tar.xz
curl -L http://pkgs.fedoraproject.org/repo/pkgs/libsndfile/libsndfile-1.0.23.tar.gz/d0e22b5ff2ef945615db33960376d733/libsndfile-1.0.23.tar.gz -o libsndfile-1.0.23.tar.gz
curl -L http://downloads.xiph.org/releases/vorbis/libvorbis-1.3.2.tar.xz -o libvorbis-1.3.2.tar.xz
curl -L http://downloads.xiph.org/releases/speex/speex-1.2rc1.tar.gz -o speex-1.2rc1.tar.gz
curl -L http://pkgs.fedoraproject.org/repo/pkgs/wavpack/wavpack-4.60.1.tar.bz2/7bb1528f910e4d0003426c02db856063/wavpack-4.60.1.tar.bz2 -o wavpack-4.60.1.tar.bz2
curl -L http://sourceforge.net/projects/libpng/files/zlib/1.2.5/zlib-1.2.5.tar.gz/download -o zlib-1.2.5.tar.gz

7z x -y sox-14.4.1.tar.bz2 && 7z x -y sox-14.4.1.tar
7z x -y flac-1.2.1.tar.gz && 7z x -y flac-1.2.1.tar
7z x -y lame-3.98.4.tar.gz && 7z x -y lame-3.98.4.tar
7z x -y libid3tag-0.15.1b.tar.gz && 7z x -y libid3tag-0.15.1b.tar
7z x -y libmad-0.15.1b.tar.gz && 7z x -y libmad-0.15.1b.tar
7z x -y libogg-1.2.2.tar.xz && 7z x -y libogg-1.2.2.tar
7z x -y libpng-1.5.1.tar.xz && 7z x -y libpng-1.5.1.tar
7z x -y libsndfile-1.0.23.tar.gz && 7z x -y libsndfile-1.0.23.tar
7z x -y libvorbis-1.3.2.tar.xz && 7z x -y libvorbis-1.3.2.tar
7z x -y speex-1.2rc1.tar.gz && 7z x -y speex-1.2rc1.tar
7z x -y wavpack-4.60.1.tar.bz2 && 7z x -y wavpack-4.60.1.tar
7z x -y zlib-1.2.5.tar.gz && 7z x -y zlib-1.2.5.tar

del sox-14.4.1.tar
del flac-1.2.1.tar
del lame-3.98.4.tar
del libid3tag-0.15.1b.tar
del libmad-0.15.1b.tar
del libogg-1.2.2.tar
del libpng-1.5.1.tar
del libsndfile-1.0.23.tar
del libvorbis-1.3.2.tar
del speex-1.2rc1.tar
del wavpack-4.60.1.tar
del zlib-1.2.5.tar

rmdir /S /Q flac
rmdir /S /Q lame
rmdir /S /Q libid3tag
rmdir /S /Q libmad
rmdir /S /Q libogg
rmdir /S /Q libsndfile
rmdir /S /Q libvorbis
rmdir /S /Q libpng
rmdir /S /Q speex
rmdir /S /Q wavpack
rmdir /S /Q zlib

ren flac-1.2.1 flac
ren lame-3.98.4 lame
ren libid3tag-0.15.1b libid3tag
ren libmad-0.15.1b libmad
ren libogg-1.2.2 libogg
ren libsndfile-1.0.23 libsndfile
ren libvorbis-1.3.2 libvorbis
ren libpng-1.5.1 libpng
ren speex-1.2rc1 speex
ren wavpack-4.60.1 wavpack
ren zlib-1.2.5 zlib

@rem Disable warning 4819 for wavpack\src\wavpack_local.h
ren wavpack\src\wavpack_local.h wavpack_local.h.old
echo #pragma warning(disable: 4819)> wavpack\src\wavpack_local.h
echo #include "wavpack_local.h.old">>wavpack\src\wavpack_local.h

@rem Download missing file: sox-14.4.1/src/speexdsp.c
curl -L http://sourceforge.net/p/sox/code/ci/sox-14.4.1/tree/src/speexdsp.c?format=raw -o sox-14.4.1/src/speexdsp.c

pushd sox-14.4.1
cd msvc10
call "%VS120COMNTOOLS%"vsvars32.bat
msbuild SoX.sln /nologo /t:Build /p:Configuration=Release /m
popd

popd
