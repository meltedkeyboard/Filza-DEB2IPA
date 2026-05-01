#!/bin/bash

# UI colors
CLR_RST="\033[0m"
CLR_ERR="\033[1;31m"
CLR_OK="\033[1;32m"
CLR_INF="\033[38;5;117m"
CLR_WARN="\033[1;33m"

DEB_PATH=""
OUT_IPA=""
DOWNLOAD_MODE=false
TEMP_DIR="_FILZA_WORK"

show_usage() {
    echo -e "${CLR_WARN}FILZA DEB TO IPA CONVERTER${CLR_RST}"
    echo -e "Usage:"
    echo -e "  $0 <path_to_deb> -o <output_ipa_path>   Convert local DEB to IPA"
    echo -e "  $0 --download -o <output_ipa_path>      Download latest DEB and convert"
    echo -e "\nExample:"
    echo -e "  $0 filza.deb -o Filza_iOS26.ipa"
    exit 1
}

check_env() {
    for tool in ar curl zip tar; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${CLR_ERR}[FAIL] Required tool '$tool' not found. Install binutils, curl, zip, and tar.${CLR_RST}"
            exit 1
        fi
    done
}

# Fetch DEB from the official server
download_deb() {
    local url="https://tigisoftware.com/cydia/com.tigisoftware.filza_4.0.1-2_iphoneos-arm.deb"
    echo -e "${CLR_INF}[INFO] Downloading Filza tweak DEB...${CLR_RST}"
    if ! curl -L --user-agent "Filza26Builder/1.0" --fail -o "temp_filza.deb" "$url"; then
        echo -e "${CLR_ERR}[FAIL] Could not download DEB file.${CLR_RST}"
        return 1
    fi
    DEB_PATH="$(pwd)/temp_filza.deb"
    return 0
}

# Unpack DEB and extract app folder
extract_assets() {
    local target_deb=$1
    echo -e "${CLR_OK}[SUCCESS] Extracting contents from: $(basename "$target_deb")${CLR_RST}"
    
    cp "$target_deb" .
    local local_deb=$(basename "$target_deb")
    
    if ! ar -x "$local_deb"; then
        echo -e "${CLR_ERR}[FAIL] 'ar' extraction failed.${CLR_RST}"
        return 1
    fi

    local data_pkg=$(ls data.tar* | head -n 1)
    if [ -z "$data_pkg" ] || ! tar -xf "$data_pkg"; then
        echo -e "${CLR_ERR}[FAIL] Data archive extraction failed.${CLR_RST}"
        return 1
    fi
    return 0
}

# Build the final IPA
pack_ipa() {
    local output=$1
    echo -e "${CLR_OK}[SUCCESS] Building IPA structure...${CLR_RST}"
    mkdir -p Payload

    if [ -d "Applications/Filza.app" ]; then
        cp -R Applications/Filza.app Payload/
    else
        find . -type d -name "Filza.app" -exec cp -R {} Payload/ \;
    fi

    [[ "$output" != *.ipa ]] && output="${output}.ipa"

    if ! zip -r "../../$output" Payload > /dev/null 2>&1; then
        echo -e "${CLR_ERR}[FAIL] Zip compression failed.${CLR_RST}"
        return 1
    fi
    return 0
}

# Parse Arguments
if [ $# -lt 3 ]; then
    show_usage
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --download)
            DOWNLOAD_MODE=true
            shift
            ;;
        -o)
            OUT_IPA="$2"
            shift 2
            ;;
        *)
            DEB_PATH="$1"
            shift
            ;;
    esac
done

# Validate input
if [ "$DOWNLOAD_MODE" = false ] && [ ! -f "$DEB_PATH" ]; then
    echo -e "${CLR_ERR}[ERROR] Local DEB file not found: $DEB_PATH${CLR_RST}"
    exit 1
fi

if [ -z "$OUT_IPA" ]; then
    echo -e "${CLR_ERR}[ERROR] Output path (-o) is required.${CLR_RST}"
    show_usage
fi

# Main Execution
clear
echo -e "${CLR_WARN}FILZA DEB TO IPA CONVERTER (iOS 26/18)${CLR_RST}"
echo -e "${CLR_WARN}GITHUB: @meltedkeyboard${CLR_RST}\n"

check_env

# Prepare workspace
rm -rf "$TEMP_DIR" && mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR" || exit 1

if [ "$DOWNLOAD_MODE" = true ]; then
    download_deb || exit 1
else
    # Resolve absolute path for local file
    DEB_PATH=$(realpath "$DEB_PATH")
fi

if extract_assets "$DEB_PATH" && pack_ipa "$OUT_IPA"; then
    cd ..
    rm -rf "$TEMP_DIR"
    echo -e "\n${CLR_OK}[DONE] File created: $OUT_IPA${CLR_RST}"
    echo -e "${CLR_INF}[INFO] Now sign it via Sideloadly or AltStore. Enjoy!${CLR_RST}"
else
    cd ..
    exit 1
fi