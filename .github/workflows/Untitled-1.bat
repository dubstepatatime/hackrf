os: Visual Studio 2017
clone_depth: 1

configuration:
  - Release

init:
  - C:\"Program Files (x86)"\"Microsoft Visual Studio 14.0"\VC\vcvarsall.bat %PLATFORM%
install:
  # Dependencies for libHackRF
  - appveyor DownloadFile "https://github.com/libusb/libusb/releases/download/v1.0.22/libusb-1.0.22.7z" -FileName "C:\libusb.7z"
  - 7z x -y "C:\libusb.7z" -o"C:\libusb"
  - appveyor DownloadFile "http://mirrors.kernel.org/sourceware/pthreads-win32/pthreads-w32-2-9-1-release.zip" -FileName "C:\pthreads-w32-release.zip"
  - 7z x -y "C:\pthreads-w32-release.zip" -o"C:\pthreads"
  - appveyor DownloadFile "http://ftp.gnome.org/pub/gnome/binaries/win32/dependencies/pkg-config_0.26-1_win32.zip" -FileName "C:\pkg-config_win32.zip"
  - 7z x -y "C:\pkg-config_win32.zip" -o"C:\pkg-config"
  # FFTW for hackrf_sweep
  - curl -fsS -o "C:\fftw-3.3.5.zip" "ftp://ftp.fftw.org/pub/fftw/fftw-3.3.5-dll64.zip"
  - 7z x -y "C:\fftw-3.3.5.zip" -o"C:\fftw"
  - cd c:\fftw
  - ps: lib /machine:x64 /def:libfftw3f-3.def
  # ARM GCC for firmware builds
  # - appveyor DownloadFile "https://developer.arm.com/-/media/Files/downloads/gnu-rm/6-2017q2/gcc-arm-none-eabi-6-2017-q2-update-win32.zip" -FileName "C:\gcc-arm-none-eabi-win32.zip"
  # - 7z x -y "C:\gcc-arm-none-eabi-win32.zip" -o"C:\gcc-arm-none-eabi"
  # - set PATH=%PATH%;c:\gcc-arm-none-eabi\bin

build_script:
  # Host library and tools
  - mkdir c:\projects\hackrf\host\build
  - cd c:\projects\hackrf\host\build
  - cmake -G "Visual Studio 14 2015 Win64" \
    -DLIBUSB_LIBRARIES="C:\libusb\MS64\dll\libusb-1.0.lib" \
    -DLIBUSB_INCLUDE_DIR="C:\libusb\include\libusb-1.0" \
    -DTHREADS_PTHREADS_INCLUDE_DIR=c:\pthreads\Pre-built.2\include \
    -DTHREADS_PTHREADS_WIN32_LIBRARY=c:\pthreads\Pre-built.2\lib\x64\pthreadVC2.lib \
    -DPKG_CONFIG_EXECUTABLE="C:\pkg-config\bin\pkg-config.exe" \
    -DFFTW_INCLUDES=C:\fftw \
    -DFFTW_LIBRARIES=C:\fftw\libfftw3f-3.lib \
    ..
  - msbuild HackRF.sln /logger:"C:\Program Files\AppVeyor\BuildAgent\Appveyor.MSBuildLogger.dll"
  # Firmware
  # - cd c:\projects\hackrf\
  # - git submodule init
  # - git submodule update
  # - '%CYG_BASH% -lc "cd $APPVEYOR_BUILD_FOLDER && firmware/appveyor.sh"'

after_build:
  - 7z a %APPVEYOR_BUILD_FOLDER%\HackRF-Windows-%APPVEYOR_REPO_COMMIT%.zip %APPVEYOR_BUILD_FOLDER%\host\build\libhackrf\src\Release\* %APPVEYOR_BUILD_FOLDER%\host\build\hackrf-tools\src\Release\* 

artifacts:
  - path: HackRF-Windows-%APPVEYOR_REPO_COMMIT%.zip
    name: HackRF-Windows-%APPVEYOR_REPO_COMMIT%