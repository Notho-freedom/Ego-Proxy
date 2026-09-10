# Ego-Proxy

Flutter development proxy and debugging tools for cross-platform mobile applications.

## 🚀 Features

- 🔧 **Proxy configuration** - Network proxy for Flutter debugging
- 📱 **Multi-platform** - Android, iOS, Web, Desktop support
- 🛠️ **DevTools integration** - Enhanced Flutter DevTools
- 📊 **Network monitoring** - Inspect API calls and traffic
- 🔍 **Backend probing** - Test backend endpoints from mobile

## 🛠️ Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Python (probe server)
- **Platforms**: Android, iOS, macOS, Windows, Linux, Web

## 📁 Project Structure

`
Ego-Proxy/
├── lib/               # Dart/Flutter source code
├── backend/           # Python backend probe
├── android/           # Android native
├── ios/               # iOS native
├── linux/             # Linux desktop
├── macos/             # macOS desktop
├── windows/           # Windows desktop
├── web/               # Web platform
├── test/              # Unit tests
└── pubspec.yaml       # Flutter dependencies
`

## 🚀 Installation

`ash
git clone https://github.com/Notho-freedom/Ego-Proxy.git
cd Ego-Proxy
flutter pub get
`

## 🏃 Running

`ash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d chrome      # Web
flutter run -d macos       # macOS
flutter run -d windows     # Windows
flutter run -d linux       # Linux
`

## 📊 Status

Active development. Core proxy and backend probe features implemented.

## 👤 Author

[Notho-freedom](https://github.com/Notho-freedom)

## 📄 License

MIT