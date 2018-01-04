#! /bin/bash -x -e

rm -rf Neutrino.dmg prepareapp

mkdir prepareapp

cp -r Neutrino.app prepareapp

/usr/local/opt/qt5/bin/macdeployqt prepareapp/Neutrino.app

python ../macdeployqtfix/macdeployqtfix.py prepareapp/Neutrino.app/Contents/MacOS/Neutrino /usr/local 
rm -rf prepareapp/macdeployqtfix*

../resources/macPackage/createdmg.sh --icon-size 96 --volname Neutrino --volicon ../resources/macPackage/dmg-icon.icns --background ../resources/macPackage/background.png --window-size 420 400 --icon Neutrino.app 90 75 --app-drop-link 320 75 Neutrino.dmg prepareapp

