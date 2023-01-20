INNO_VERSION=6.2.1
TEMP_DIR=/tmp/photon-tar
BUNDLE_DIR=build/linux/x64/release/bundle
MIRRORLIST=${PWD}/build/mirrorlist
#android
apk:
		mv build/app/outputs/apk/release/app-release.apk build/photon-android-all-arch.apk
#linux    
tar:
		mkdir -p $(TEMP_DIR)\
		&& cp -r $(BUNDLE_DIR)/* $(TEMP_DIR)\
		&& cp linux/photon.desktop $(TEMP_DIR)\
		&& cp assets/images/icon.png $(TEMP_DIR)\
		&& cp linux/com.github.abhi16180.photon.appdata.xml $(TEMP_DIR)\
		&& tar -cJf build/Photon-linux-x86_64.tar.xz -C $(TEMP_DIR) .\
		&& rm -rf $(TEMP_DIR)


appimage:
				 appimage-builder --recipe AppImageBuilder.yml\
				 && mv Photon-*-x86_64.AppImage build


#windows


innoinstall:
						powershell curl -o build\installer.exe http://files.jrsoftware.org/is/6/innosetup-${INNO_VERSION}.exe
		 				powershell build\installer.exe /verysilent /allusers /dir=build\iscc

inno:
		 powershell .\build\iscc\iscc.exe scripts\windows-setup-creator.iss

choco:
			powershell cp dist\Photon-windows-x86_64-setup.exe choco-struct\tools
			powershell choco pack .\choco-struct\photon.nuspec  --outputdirectory dist



msix:
	flutter pub run msix:create


# On local machine 

winandroid:
	flutter pub get packages
	flutter build windows
	flutter build apk --split-per-abi

	
	
	