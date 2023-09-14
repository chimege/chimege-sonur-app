# Chimege Sonur VoiceOver App

A Mongolian screen reader VoiceOver app. See for more information: https://sonur.chimege.com/

## Requirements
MacOS 13.0+ iOS 16.0+ Xcode 14.0+

## Setup
1. Double click ChimegeSonur.xcodeproj file
2. Wait Until Xcode automatically fetches dependencies. (espeak-ng, TextNormalizerSwift)
3. Click on ChimegeSonur project.
4. Open Signing and Capabilities tab.
5. Select your team and change Bundle Identifier by unique identifier on both targets. (ChimegeSonur, Synth, Synth identifier should has ChimegeSonur identifier as a prefix)
6. Create new group on App Groups field and tick on both targets. (ChimegeSonur, Synth, App Group should contain your team name.)

## Steps to Run
7. Change Build Target to target device.
8. Click Product -> Run on top bar.

## Steps to Build and upload App Store
9. Change Build Target to Any Mac (for macos build) or Any iOS Device (for ios build).
10. Open General tab and set Version and Build fields.
11. Product -> Build on top navigation bar.
12. Product -> Archive on top bar.
13. Upload to App Store. Good Luck
