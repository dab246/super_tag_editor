#!/usr/bin/env bash
# fail if any commands fails
set -e
# debug log
set -x

flutter pub get

cd example
flutter pub get