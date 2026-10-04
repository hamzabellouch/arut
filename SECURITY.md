# Security Policy

## Supported Versions

The following versions of ARUT are currently supported with security, privacy, and stability updates.

| Version       | Supported          |
| ------------- | ------------------ |
| + 0.0.1       | :white_check_mark: |
| < 0.0.1       | :x:                |



## Reporting a Vulnerability

If you discover a security vulnerability, privacy issue, unexpected behavior with permissions, or any issue that could negatively affect users or their data safety, please report it responsibly.

### Before Reporting
Please make sure that:
- The issue is reproducible
- You are using the latest supported version of ARUT
- The issue is not caused by third-party modifications, custom ROMs, or unsupported Android / Host environments

### How to Report
You can report vulnerabilities through:
- GitHub Issues (for non-sensitive reports and general bug reports)
- E-mail: hamzabellouchcontact@gmail.com / [Froms](https://docs.google.com/forms/d/e/1FAIpQLSf87zkBsPRiUX19qF42vekAwgV_bW2EWZZPEThTo8PFIOFc0w/viewform?usp=header) 

When reporting, please include:
- Device model and Android OS version
- Host operating system (Windows, Linux, or macOS)
- ARUT application version and relay server flavor (Java or Rust)
- Steps to reproduce the issue
- Screenshots, logcat outputs, or host relay logs if available
- A clear explanation of the potential security or privacy impact

### Response Policy
Security reports are reviewed as quickly as possible.  
If the issue is confirmed:
- The vulnerability will be investigated, verified, and patched
- A fix will be included in the next update release
- Credit may be given to the reporter if requested

If the report is invalid, incomplete, or not reproducible, it may be closed without action.



## Security & Architecture Notes

ARUT is designed with a strict **Privacy-First & Local-Only Security Model**:

- **Root-Free Operation:** ARUT does not require root privileges on either the Android client or host computer. It relies entirely on official Android system APIs (`VpnService`) and standard user-space host sockets.
- **Local & Direct Tunneling:** Packet forwarding operates exclusively over a direct, local USB cable connection via `adb reverse`. Traffic is relayed directly between the device and host without routing through remote servers.
- **Transparent Packet Relaying:** ARUT performs stateless Level 3 (IP) to Level 5 (TCP/UDP) protocol conversion. It does not perform SSL/TLS termination, payload inspection, injection, or persistent payload logging.
- **Zero Telemetry:** No analytics, device identifiers, diagnostic tracking, or user telemetry data are collected or transmitted to external servers.
- **Transient Memory Handling:** All IP and transport packet buffers held during routing are stored temporarily in volatile memory (RAM) and immediately released upon transmission or session termination.
