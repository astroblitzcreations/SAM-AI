# SAM Network Guard WFP component

This directory defines the native boundary for SAM-AI's optional pre-connect firewall mode. The normal application does **not** install or silently load a kernel driver.

## Why this exists

The standard Network Guard polls Windows' supported process, TCP, Authenticode, service, startup, and firewall APIs. It can react quickly and create remembered Windows Firewall rules, but Windows may already have authorized the first packet by the time a user-space app sees a connection.

True ZoneAlarm-style hold-and-decide behavior requires a Windows Filtering Platform callout at `FWPM_LAYER_ALE_AUTH_CONNECT_V4/V6` and `FWPM_LAYER_ALE_AUTH_RECV_ACCEPT_V4/V6`. The callout must pend classification, send a bounded request to a Windows service, and complete with permit or block. A hard timeout must default to the saved policy so a crashed UI cannot strand networking.

## Required production components

1. `SamNetworkGuardWfp.sys`: minimal WDF/WFP callout driver. No UI, DNS, HTTP, model, or policy database code belongs in kernel mode.
2. `SamNetworkGuardService.exe`: LocalService broker that owns the filter engine session, validates signed messages, stores rules, and talks to the SAM desktop process over an ACL-restricted named pipe.
3. SAM-AI UI: displays the request and returns Allow Once, Remember Allow, or Block.
4. Signed installer/uninstaller: transactional install, recovery rollback, service health check, and explicit consent.

The wire contract begins in `SamNetworkGuardProtocol.h`.

## Mandatory safety rules

- Fail open to the user's last persisted policy if the service or UI is unavailable; never leave an operation pended indefinitely.
- Never block loopback traffic used by SAM-AI and llama.cpp.
- Cap pending requests, payload lengths, and decision time.
- Authenticate every user-mode client and restrict the device/pipe ACL.
- Keep all parsing and policy storage in user mode.
- Provide Safe Mode and installer rollback paths.
- Do not install a test-signed driver on an end-user machine.

## Signing blocker

A distributable x64 Windows kernel driver requires a production certificate/signing pipeline and Microsoft attestation or WHQL submission. Secure Boot normally rejects an unsigned build. Until that release process exists, SAM-AI reports `STANDARD OBSERVER`; a properly installed and running `SamNetworkGuardWfp` service changes the status to `KERNEL INTERCEPT`.

This source boundary is intentionally not included as a runnable driver in the Windows ZIP. Shipping an unsigned or unreviewed kernel binary would make the product less secure.
