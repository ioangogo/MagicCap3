#!/bin/sh
cd config/
npm i
npm run build
cd ..
go get
CURRENT_CWD=$(pwd)
cd ..
go get github.com/gobuffalo/packr/packr
cd $CURRENT_CWD
~/go/bin/packr build
mv ./MagicCap ./magiccap-darwin
