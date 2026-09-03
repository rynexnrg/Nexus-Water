# Nexus Water

Clientseitige SwiftUI-Wassertracking-App mit Tagesziel, Motivation, Cloud Streak und Joker-Tag.

## Xcode-Projekt erzeugen

Voraussetzung: macOS mit Xcode und [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
xcodegen generate
open NexusWater.xcodeproj
```

Das Deployment Target ist iOS 17.0. Trinkdaten und Einstellungen werden lokal mit `UserDefaults` gespeichert. Eine Apple-Watch-Synchronisierung kann später über WatchConnectivity ergänzt werden; die App funktioniert auch offline.

## GitHub Build

Der Workflow unter `.github/workflows/ios.yml` erzeugt auf einem macOS-Runner das Xcode-Projekt mit XcodeGen und baut es fuer den iOS Simulator.
