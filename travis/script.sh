#!/bin/sh

set -e

xctool -workspace VZLab.xcworkspace -scheme VZLab -sdk iphonesimulator test

