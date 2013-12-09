# hatch

hatch is a minimalistic package builder / installer for powershell.

 - hatch is not a package manager.
 - Script which name is beginning with `install-` is silent installer.
 - Other scripts are build script.
   - Just build, and do not install / copy anything.


## Install Visual Studio Express 2013 for Windows Desktop silently

```
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/t-mat/hatch/master/install-visual-studio-express-2013-for-windows-desktop.ps1'))"
```


## build boost-1.54.0

```
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://raw.github.com/t-mat/hatch/master/boost-1.54.0.ps1'))"
```


## Testing

```
start hatch-test-server.ps1
powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('http://localhost:8000/YOUR-OWN-NEW-SCRIPT.ps1'))"
```
