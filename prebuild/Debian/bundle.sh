#!/usr/bin/env sh

for lib in $(lddtree -l ./build/Release/canvas.node|sed -r -e '/canvas.node$/d'); do
  cp "${lib}" ./build/Release
done
