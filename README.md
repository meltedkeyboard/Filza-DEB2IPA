# Filza-DEB2IPA

Bash tool to convert Filza DEB to IPA for iOS 26 and iOS 18. No macOS required.

## Requirements

* `binutils` (for `ar`)
* `curl`
* `zip`
* `tar`

## Installation

1. Clone this repository (or just download script)
2. Run `chmod +x Filza-DEB2IPA.sh` (make it executable)
3. Run script `./Filza-DEB2IPA.sh` (`sh ./Filza-DEB2IPA.sh` or any other bash interpreter)
4. Sideload with any method you like.

## Usage

```bash
# Convert local .deb
./Filza-DEB2IPA.sh <path_to_deb> -o <output_ipa_path>
# Download and convert
./Filza-DEB2IPA.sh --download -o <output_ipa_path>
```
--- 

* No exploits included.
* Requires manual signing.
* Works on Linux.
* Inspired by Filza26Maker by GeoSn0w