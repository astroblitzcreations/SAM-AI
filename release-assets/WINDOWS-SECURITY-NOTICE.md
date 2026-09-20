# Windows download and publisher notice

SAM-AI is distributed directly from the Astroblitz Creations GitHub repository.
Windows SmartScreen may show **Unknown publisher** because the current release is
not yet Authenticode-signed with a commercial code-signing certificate. Creating
an unsigned installer would not remove that warning.

Before running SAM-AI, download it only from the official repository and compare
the ZIP's SHA-256 checksum with the value published in its GitHub release notes.
Do not run a copy whose checksum differs.

Future releases can remove the Unknown publisher label after Astroblitz Creations
obtains a trusted Windows code-signing certificate and signs both the application
and any installer. The SAM-AI executable already contains product, company, and
version metadata, but metadata is not a substitute for a digital signature.
