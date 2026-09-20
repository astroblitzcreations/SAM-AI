# SAM-AI v1.2.2

## Fixed in v1.2.2

- Unknown network owners now default to investigating the actual remote IP instead of searching for “unknown Windows process.”
- Connection alerts offer IP Lookup, Search App + IP, Ask SAM, and Copy Details alongside allow/block decisions.
- Connection right-click research retains the selected remote address, ports, state, direction, PID, executable, and local endpoint.
- IP Lookup opens the exact address on IPinfo; combined search includes the executable name and remote IP.
- Ask SAM receives the complete observed connection context and clearly distinguishes local analysis from current online IP ownership/reputation.
- A dedicated Guard Policies tab groups paired inbound/outbound rules into clear per-app Allowed or Blocked decisions.
- Policy rows support right-click research, Ask SAM, copy/open path, Allow, Block, enable, disable, and removal actions.

## Fixed in v1.2.1

## Fixed in v1.2.1

- Process-details OK and title-bar close controls now reliably dismiss and free the dialog.
- Security dialogs and right-click menus use SAM-AI's dark cyan panel, border, hover, typography, and button styling.
- Right-click selection now uses each Tree's GUI coordinates, reliably selecting the row under the pointer before opening its menu.
- Ascending and descending comparators now return strict ordering for equal values, fixing Godot's `bad comparison function` errors.

## New in v1.2.0

## New in v1.2.0

- ZoneAlarm-style Network Guard alerts for new external connections and non-loopback inbound listeners, with Allow Once, Remember Allow, Block App, and Search actions.
- Reversible STOP INTERNET emergency lockdown uses two clearly named SAM firewall rules without disabling network adapters.
- Sortable running-app and connection columns, double-click process details, and full right-click menus.
- Process menus include Ask SAM, online research, block/unblock, copy name/PID/path, open file location, End Task, and administrator Force End.
- A deep Verify All Signatures scan uses Windows Authenticode and improves publisher/rating information.
- New Windows startup-app, service, and firewall-rule inventories expose common persistence locations.
- Firewall rules show direction, action, state, profile, program when available, and owner. SAM-owned rules can be enabled, disabled, or removed from their context menu.

Connection alerts are user-space observations shown immediately after Windows reports activity. SAM-AI does not install a kernel network driver and therefore cannot hold the first packet while waiting for a decision.

## New in v1.1.0

- SAM Network Guard adds a live, local view of running applications, TCP listeners, and active connections.
- Selected apps can be explained by SAM, researched in a browser, blocked/unblocked through named Windows Firewall rules, or ended after explicit confirmation.
- A compact header badge shows Network Guard state and SAM-managed block-rule count when the feature is enabled.
- Modules now includes a clearly warned factory reset that removes only SAM-AI private app data and returns to first-run setup; downloaded models and runtimes are preserved.
- The project-session handle is now a compact `<` / `>` control instead of a tall blank strip.
- Long views expose visible scrollbars so hidden content is discoverable.
- Slow CPU inference gets a ten-minute first-token allowance and a progress notice instead of failing after 90 seconds while the model is still working.

SAM-AI is a private, local and offline desktop AI interface created by Steadyforge
of Astroblitz Creations and Makazhan.

## First-run clarity update

- Bundles an official Windows x64 CPU llama.cpp runtime, so new users no longer
  need to find `llama-server.exe` before starting SAM.
- Automatically detects the bundled runtime and re-checks setup after the
  Microsoft Visual C++ installer finishes.
- Shows detected physical RAM, graphics adapter, runtime mode, Sandbox limits,
  model size, and plain-language recommendations in first-run setup.
- Warns when a CPU model exceeds physical RAM but still allows an informed
  "start anyway" attempt; the engine timeout prevents a permanent hang.
- Uses CPU-safe GPU-layer settings when CUDA/Vulkan libraries are unavailable.
- Adds an official latest-release link for llama.cpp runtime updates.
- Adds llama.cpp file logging and a 90-second first-token timeout so startup or
  inference failures produce an actionable error instead of thinking forever.
- Uses safer context/output defaults on computers with 6 GB RAM or less.
- Corrects Windows Sandbox memory reporting and clarifies CPU versus GPU loading.
- Labels CUDA acceleration as optional when the bundled CPU runtime is selected.
- Highlights the next required setup button and automatically notices when the
  Microsoft runtime installation finishes.
- Stops refreshing setup text when nothing changed, allowing users to select and
  copy diagnostics for support.
- Removes first-launch command-window probes and disables the console wrapper.
- Adds Windows product/company/version metadata to the executable.

## Windows SmartScreen

This build is not yet Authenticode-signed, so Windows may display **Unknown
publisher**. An unsigned installer would show the same trust warning. Download
only from the official Astroblitz Creations GitHub repository and verify the
SHA-256 checksum published with this release. A trusted code-signing certificate
is required to remove the publisher warning in a future release.

## Install

1. Extract the complete ZIP into one folder.
2. Keep `SAM-AI.exe`, `SAM-AI.pck`, and the `engine` and `voice` folders together.
3. Run `SAM-AI.exe`.
4. Open Modules and use the setup checker to select or download a GGUF model and llama.cpp runtime.
5. Optional: configure Kokoro and Whisper using `voice/README.txt`.

Large GGUF and voice model files are intentionally not bundled. Users select their
own compatible local models from the Modules tab.

Support development: https://buymeacoffee.com/astroblitzcreations
