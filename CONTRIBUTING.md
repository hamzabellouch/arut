# Contributing

Thank you for your interest in contributing to **ARUT**! ARUT provides seamless, rootless Android reverse tethering over USB via `adb`, allowing connected Android devices to access the internet connection of their host computer using a high-performance Java or Rust relay server and an Android `VpnService` client.

Before submitting a bug report or feature request, please search existing issues (including closed ones) to ensure it hasn't already been reported or discussed. If there are no duplicates, feel free to submit a new issue using the appropriate template.

**Please note:** Issues that do not use existing templates or lack sufficient detail may be closed without review.

For questions or any other ideas to improve, you can join our official e-mail : hamzabellouchcontact@gmail.com or [Social Media platforms](https://sites.google.com/view/hamzabellouch/).


## Disclaimer

ARUT is an active open-source project focused on delivering fast, lightweight, and reliable reverse tethering without root privileges. While we strive for code quality, rock-solid network stability, and minimal latency, contributions and feedback are always welcome to improve performance, cross-platform compatibility, and developer experience.



## Bug Reports

When submitting a bug report, please make sure your issue contains **sufficient information** to reproduce the problem. Useful details include:

- Android device model and Android OS version
- Host computer operating system (Windows, Linux, or macOS)
- ARUT version and relay flavor in use (**Rust** or **Java**)
- ADB version (`adb version`) and connection state
- Steps to reproduce the bug
- Terminal/relay console output, Android `logcat` logs, or screenshots if applicable



## Feature Requests

ARUT aims to remain a lightweight, fast, and robust reverse tethering utility for Android. We welcome suggestions that enhance connection stability, protocol handling, CLI capabilities, or multi-device management.

When suggesting a new feature, please consider:
- **Relevance:** Does the feature fit the core goal of reverse tethering, network routing, or tunnel management?
- **Performance & Efficiency:** Does it preserve minimal CPU and memory footprint across the Android client and relay backends?
- **Root-Free Safety:** Does it adhere to our rootless architecture and respect Android system boundaries?



## Pull Requests

If you wish to contribute directly by submitting code:

1. **Discuss First:** Leave a comment under an existing issue or open a new issue describing the changes you plan to make before writing code.
2. **Avoid Conflicts:** Comment on the issue to let others know you are working on it to prevent duplicate efforts.
3. **Follow Code Style:** Ensure your code follows established conventions:
   - Android client & Java relay: Java 17 standards and Android guidelines.
   - Rust relay: idiomatic Rust formatting (`cargo fmt`) and lints (`cargo clippy`).



## New Contributors

If you are new to the project:
- Browse our open issues for beginner-friendly tasks marked as `good first issue` or `help wanted`.
- Feel free to ask clarifying questions directly on the issue thread!



## Building From Source

To build ARUT locally:

1. **Prerequisites:**
   - [Android Studio](https://developer.android.com/studio) / Android SDK (API Level 24+)
   - JDK 17 or higher
   - [Rust Toolchain](https://www.rust-lang.org/) (Cargo & Rustc) for the Rust relay flavor
   - Android Debug Bridge (`adb`) installed and available in your `PATH`

2. **Steps:**
   ```bash
   # Clone the repository
   git clone https://github.com/hamzabellouch/arut.git
   cd arut

   # Build Android Client APK
   cd application
   ./gradlew assembleRelease
   cd ..

   # Build Java Relay Server
   cd relay/java
   ../../application/gradlew assembleRelease
   cd ../..

   # Build Rust Relay Server
   cd relay/rust
   cargo build --release
   cd ../..
   ```
