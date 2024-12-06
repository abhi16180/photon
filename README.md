## Photon 

<h1 >Welcome to Photon👋</h1><br>
<p align="center"> <img style="border-radius:20px" src="photon.png" width="400px"></p>
<p>
  <img alt="Version" src="https://img.shields.io/badge/version-2.0.0-blue.svg?cacheSeconds=2592000" />
  <a href="https://twitter.com/AbhilashHegde9" target="_blank">
    <img alt="Twitter: AbhilashHegde9" src="https://img.shields.io/twitter/follow/AbhilashHegde9.svg?style=social" />
  </a>
  
  [![Github All Releases](https://img.shields.io/github/downloads/abhi16180/photon/total.svg)]()
  [![Github Latest Release (all)](https://img.shields.io/github/downloads/abhi16180/photon/v2.0.0/total)]()
  [![Commits/week](  https://img.shields.io/github/commit-activity/w/abhi16180/photon)]()
  [![CodeFactor](https://www.codefactor.io/repository/github/abhi16180/photon/badge)](https://www.codefactor.io/repository/github/abhi16180/photon)
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
- **Share raw text**<br>
  You can share raw text between devices. Store raw text as txt file or copy to clipboard.
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
- macOS   
- iOS     
  - *Coming soon*


## Downloads

- Android 
<br>
<a href='https://play.google.com/store/apps/details?id=dev.abhi.photon&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1' ><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width=240px/></a>
<br>
<a href="https://apt.izzysoft.de/fdroid/index/apk/dev.abhi.photon"><img src="https://gitlab.com/IzzyOnDroid/repo/-/raw/master/assets/IzzyOnDroid.png" width=240px> </a>
<br>

- Windows
<br>
<a title="Microsoft Corporation, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0&gt;, via Wikimedia Commons" href="https://github.com/abhi16180/photon/releases/download/v1.2.0/photon-windows-1.2.0.exe"><img width="128" alt="Windows 10x Icon" src="https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Windows_10x_Icon.png/512px-Windows_10x_Icon.png" width=128px></a>
<br>
<br>
- macOS
<br>
<a title="Apple Inc., Public domain, via Wikimedia Commons" href="https://github.com/abhi16180/photon/releases/download/v1.2.0/photon-macos-x86_64-v1.2.0.dmg"><img width="128" alt="Finder Icon macOS Big Sur" src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Finder_Icon_macOS_Big_Sur.png/512px-Finder_Icon_macOS_Big_Sur.png" width=240px></a> 
<br>
<br>
- Linux (bundle)
<br>
<a title="https://github.com/icons8/flat-color-icons/graphs/contributors, MIT &lt;http://opensource.org/licenses/mit-license.php&gt;, via Wikimedia Commons" href="https://github.com/abhi16180/photon/releases/download/v1.2.0/photon-linux-bundle-v1.2.0.tar.gz"><img width="128" alt="Icons8 flat linux" src="https://upload.wikimedia.org/wikipedia/commons/thumb/f/f1/Icons8_flat_linux.svg/512px-Icons8_flat_linux.svg.png" width=240px></a>
<br>
<a href="https://github.com/abhi16180/photon/releases/">All releases</a><br>


## To build app
```sh
flutter pub get packages
flutter run
```

### FAQ / Notes: 
- The **LICENSE** has been updated to GPL3 from MIT 
- **File transfer location:** Now you can edit file saving location. By default files will be stored at internal_storage/Download/Photon directory.
![image](https://user-images.githubusercontent.com/63426722/191982511-b5d6fab2-7fb9-4588-b014-7957c4b1829d.png)
- If you run the program with `flutter run` and **if you see a blank application window instead of the UI**, try running `flutter run --enable-software-rendering` instead. 



## Author

👤 **Abhilash Hegde**

* Twitter: [@AbhilashHegde9](https://twitter.com/AbhilashHegde9)

## Show your support

Give a ⭐️ if this project helped you!
<br>
You can support me by,
<br>
<a href="https://www.buymeacoffee.com/abhi1.6180" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
<br>
### UPI payment 
<img src="snapshots/qr.jpg" alt="hegdeabhilash19@oksbi">
### Icon credits 

<a href="https://creativecommons.org/licenses/by-sa/4.0">Windows icon - Microsoft Corporation, CC BY-SA 4.0, via Wikimedia Commons</a>
<br>
<a href="https://commons.wikimedia.org/wiki/File:Finder_Icon_macOS_Big_Sur.png">Apple Icon - Apple Inc., Public domain, via Wikimedia Commons</a>
<br>
<a href="http://opensource.org/licenses/mit-license.php">Linux Icon - https://github.com/icons8/flat-color-icons/graphs/contributors, MIT , via Wikimedia Commons</a>
