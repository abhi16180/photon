<h1 >Welcome to Photon👋</h1><br>
<p align="center"> <img style="border-radius:20px" src="photon.png" width="400px"></p>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-1.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="https://twitter.com/AbhilashHegde9" target="_blank">
    <img alt="Twitter: AbhilashHegde9" src="https://img.shields.io/twitter/follow/AbhilashHegde9.svg?style=social" />
  </a>
</p>

> Photon is a cross-platform file-transfer application built using flutter. It uses http to transfer files between devices.You can transfer files between devices that run Photon.(*No wifi router is required ,you can use  hotspot*)


## Snapshots

<img src="snapshots/photon_desktop.png">
<img src="snapshots/photon_mobile.png">



## Current features

- **Cross-platform support**<br>
  For instance you can transfer files between Android and Windows
- **Transfer multiple files**<br>
  You can pick any number of files.
- **Pick files faster**<br>
  Most of the apps use <a href='https://github.com/miguelpruivo/flutter_file_picker'>file_picker</a> for picking the files. But for android it caches files before retrieving the paths. If the file size is large it will result in considerable amount of delay. So I have tweaked <a href='https://github.com/abhi16180/flutter_file_picker'>file_picker</a> to avoid caching(android) *unless it is required (some files need to be cached)*. No matter how many files are selected ,paths will be retrieved within no time.
  (Note:Caching issue is android specific)
- **Smooth UI**<br>
  Material You design.
- **Works between the devices connected via mobile-hotspot / between the devices connected to same router (same local area network)**

- **Uses cryptographically secure secret code generation for authentication (internally).**<br>
 Even though the files are streamed at local area network,files cannot be downloaded/received without using Photon. No external client like browser can get the files using url,as secret code is associated with url. It will be regenerated for every session.
- **Supports high-speed data transfer** <br>
  Photon is capable of transferring files at a very high rate but it depends upon the wifi bandwidth.
(No internet connection required)
## Platforms
- Android
- Windows 
- Linux

- iOS     
  - *Coming soon*
- macOS   
  - *Coming soon*

## Downloads
<a href="https://github.com/abhi16180/photon/releases/download/v1.0.0/photon_ARM64bit_v1.0.0.apk">Android 64bit ARM (.apk)</a><br>
<a href="https://github.com/abhi16180/photon/releases/download/v1.0.0/photon_windows_v1.0.0.zip">Windows (.zip)</a><br>
<a href="https://github.com/abhi16180/photon/releases/download/v1.0.0/photon_linux_v1.0.0.tar.gz">Linux (.tar.gz)</a><br>

### Note:- 
>The source code doesn't have any platform specific dependencies.But I don't have machines to test app on iOS and macOS ,if you have the respective machine you can build and test it out.

## To build app
```sh
flutter pub get packages
flutter run
```



## Author

👤 **Abhilash Hegde**

* Twitter: [@AbhilashHegde9](https://twitter.com/AbhilashHegde9)
* Github: [@abhi16180](https://github.com/abhi16180)

## Show your support

Give a ⭐️ if this project helped you!

