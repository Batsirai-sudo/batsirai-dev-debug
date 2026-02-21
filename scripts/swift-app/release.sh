###!/usr/bin/env bash
##
##
### ── Colors ────────────────────────────────────────────────────────────────────
##RED='\033[0;31m'
##GREEN='\033[0;32m'
##YELLOW='\033[1;33m'
##CYAN='\033[0;36m'
##BOLD='\033[1m'
##NC='\033[0m'
##
##log()    { echo -e "${CYAN}▶ $1${NC}"; }
##ok()     { echo -e "${GREEN}✓ $1${NC}"; }
##warn()   { echo -e "${YELLOW}⚠ $1${NC}"; }
##error()  { echo -e "${RED}✗ $1${NC}"; exit 1; }
##
##echo ""
##echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
##echo -e "${BOLD}║     DevDebug Release Builder     ║${NC}"
##echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
##echo ""
##
##release_dev_debug_app() {
##
### ── Config ────────────────────────────────────────────────────────────────────
##DESKTOP="$HOME/Desktop"
##APP_NAME="DevDebug"
##APP_PATH="$DESKTOP/$APP_NAME.app"
##SPARKLE_GENERATE_APPCAST="/Users/batsiraimuchareva/Library/Developer/Xcode/DerivedData/DevDebug-egqrrkgewjujhsfzcdnsvlajszgj/SourcePackages/artifacts/sparkle/Sparkle/bin/generate_appcast"
##
### ── Prompt for version ────────────────────────────────────────────────────────
##echo -e "${BOLD}Enter release version (e.g. 1.2.0):${NC}"
##read -r VERSION
##
##if [[ -z "$VERSION" ]]; then
##  error "Version cannot be empty"
##fi
##
##echo ""
##log "Building release v$VERSION"
##
### ── Validate app exists on Desktop ───────────────────────────────────────────
##if [ ! -d "$APP_PATH" ]; then
##  error "Could not find $APP_PATH — export your archive to the Desktop first"
##fi
##ok "Found $APP_PATH"
##
### ── Output paths ──────────────────────────────────────────────────────────────
##RELEASES_DIR="$DESKTOP/releases/$VERSION"
##DMG_NAME="DevDebug-$VERSION.dmg"
##ZIP_NAME="DevDebug-$VERSION.zip"
##DMG_PATH="$RELEASES_DIR/$DMG_NAME"
##ZIP_PATH="$RELEASES_DIR/$ZIP_NAME"
##APPCAST_PATH="$RELEASES_DIR/appcast.xml"
##
##mkdir -p "$RELEASES_DIR"
##ok "Created $RELEASES_DIR"
##
### ── Sign the node executable ──────────────────────────────────────────────────
##log "Signing embedded node binary..."
##NODE_BIN="$APP_PATH/Contents/Resources/devdebug-server-arm64"
##
##if [ -f "$NODE_BIN" ]; then
##  codesign --force --sign - "$NODE_BIN"
##  ok "Signed $NODE_BIN"
##else
##  warn "Node binary not found at $NODE_BIN — skipping"
##fi
##
### ── Deep sign the app ─────────────────────────────────────────────────────────
##log "Deep signing $APP_NAME.app..."
##codesign --force --deep --sign - "$APP_PATH"
##ok "App signed"
##
### ── Create DMG ────────────────────────────────────────────────────────────────
##log "Creating DMG..."
##hdiutil create \
##  -volname "$APP_NAME" \
##  -srcfolder "$APP_PATH" \
##  -ov \
##  -format UDZO \
##  "$DMG_PATH"
##ok "Created $DMG_PATH"
##
### ── Generate appcast with Sparkle signature ───────────────────────────────────
##log "Generating appcast with Sparkle signature..."
##
##if [ -f "$SPARKLE_GENERATE_APPCAST" ]; then
##  "$SPARKLE_GENERATE_APPCAST" \
##    --ed-key-file ~/.sparkle_private_key \
##    --download-url-prefix "https://yourname.github.io/DevDebug/releases/$VERSION/" \
##    --output-path "$APPCAST_PATH" \
##    "$RELEASES_DIR"
##  ok "Appcast generated at $APPCAST_PATH"
##else
##  warn "generate_appcast not found at expected path — skipping appcast generation"
##  warn "Path checked: $SPARKLE_GENERATE_APPCAST"
##fi
##
### ── Create zip (DMG + appcast) ────────────────────────────────────────────────
##log "Creating zip archive..."
##cd "$RELEASES_DIR"
##zip -r "$ZIP_PATH" "$DMG_NAME" $([ -f "$APPCAST_PATH" ] && echo "appcast.xml")
##ok "Created $ZIP_PATH"
##
### ── Summary ───────────────────────────────────────────────────────────────────
##echo ""
##echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
##echo -e "${BOLD}║         Release Complete ✓       ║${NC}"
##echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
##echo ""
##echo -e "  ${CYAN}Version:${NC}  $VERSION"
##echo -e "  ${CYAN}Folder:${NC}   $RELEASES_DIR"
##echo -e "  ${CYAN}DMG:${NC}      $DMG_NAME"
##echo -e "  ${CYAN}Zip:${NC}      $ZIP_NAME"
##[ -f "$APPCAST_PATH" ] && echo -e "  ${CYAN}Appcast:${NC}  appcast.xml"
##echo ""
##
### ── Open releases folder ──────────────────────────────────────────────────────
##open "$RELEASES_DIR"
##}
#
#
##!/bin/bash
#set -e
#
## ── Colors ────────────────────────────────────────────────────────────────────
#RED='\033[0;31m'
#GREEN='\033[0;32m'
#YELLOW='\033[1;33m'
#CYAN='\033[0;36m'
#BOLD='\033[1m'
#NC='\033[0m'
#
#log()   { echo -e "${CYAN}▶ $1${NC}"; }
#ok()    { echo -e "${GREEN}✓ $1${NC}"; }
#warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
#error() { echo -e "${RED}✗ $1${NC}"; exit 1; }
#
#echo ""
#echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
#echo -e "${BOLD}║     DevDebug Release Builder     ║${NC}"
#echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
#echo ""
#
## ── Config ────────────────────────────────────────────────────────────────────
#DESKTOP="$HOME/Desktop"
#APP_NAME="DevDebug"
#APP_PATH="$DESKTOP/DevDebug/DevDebug$APP_NAME.app"
#
## Auto-discover generate_appcast from any DevDebug DerivedData folder
#SPARKLE_GENERATE_APPCAST=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
#  -path "*/sparkle/Sparkle/bin/generate_appcast" 2>/dev/null | head -1)
#
#release_dev_debug_app() {
## ── Prompt for version ────────────────────────────────────────────────────────
#echo -e "${BOLD}Enter release version (e.g. 1.2.0):${NC}"
#read -r VERSION
#
#if [[ -z "$VERSION" ]]; then
#  error "Version cannot be empty"
#fi
#
#echo ""
#log "Building release v$VERSION"
#
## ── Validate app exists on Desktop ───────────────────────────────────────────
#if [ ! -d "$APP_PATH" ]; then
#  error "Could not find $APP_PATH — export your archive to the Desktop first"
#fi
#ok "Found $APP_PATH"
#
## ── Output paths ──────────────────────────────────────────────────────────────
#RELEASES_DIR="$DESKTOP/releases/$VERSION"
#DMG_NAME="DevDebug-$VERSION.dmg"
#ZIP_NAME="DevDebug-$VERSION.zip"
#DMG_PATH="$RELEASES_DIR/$DMG_NAME"
#ZIP_PATH="$RELEASES_DIR/$ZIP_NAME"
#APPCAST_PATH="$RELEASES_DIR/appcast.xml"
#
#mkdir -p "$RELEASES_DIR"
#ok "Created $RELEASES_DIR"
#
## ── Sign node binary ──────────────────────────────────────────────────────────
#log "Signing embedded node binary..."
#NODE_BIN="$APP_PATH/Contents/Resources/devdebug-server-arm64"
#
#if [ -f "$NODE_BIN" ]; then
#  codesign --force --sign - "$NODE_BIN"
#  ok "Signed node binary"
#else
#  warn "Node binary not found at $NODE_BIN — skipping"
#fi
#
## ── Deep sign the app ─────────────────────────────────────────────────────────
#log "Deep signing $APP_NAME.app..."
#codesign --force --deep --sign - "$APP_PATH"
#ok "App signed"
#
## ── Create DMG ────────────────────────────────────────────────────────────────
#log "Creating DMG..."
#hdiutil create \
#  -volname "$APP_NAME" \
#  -srcfolder "$APP_PATH" \
#  -ov \
#  -format UDZO \
#  "$DMG_PATH"
#ok "Created $DMG_NAME"
#
## ── Generate appcast with Sparkle signature ───────────────────────────────────
#log "Generating appcast with Sparkle signature..."
#
#if [ -n "$SPARKLE_GENERATE_APPCAST" ] && [ -f "$SPARKLE_GENERATE_APPCAST" ]; then
#  ok "Found generate_appcast at: $SPARKLE_GENERATE_APPCAST"
#  "$SPARKLE_GENERATE_APPCAST" \
#    --download-url-prefix "https://yourname.github.io/DevDebug/releases/$VERSION/" \
#    --output-path "$APPCAST_PATH" \
#    "$RELEASES_DIR"
#  ok "Appcast generated"
#else
#  warn "generate_appcast not found in DerivedData — skipping appcast"
#  warn "Make sure you've built the project at least once with Sparkle added"
#fi
#
## ── Create zip (DMG + appcast) ────────────────────────────────────────────────
#log "Creating zip archive..."
#cd "$RELEASES_DIR"
#
#FILES_TO_ZIP="$DMG_NAME"
#[ -f "appcast.xml" ] && FILES_TO_ZIP="$FILES_TO_ZIP appcast.xml"
#
#zip -r "$ZIP_PATH" $FILES_TO_ZIP
#ok "Created $ZIP_NAME"
#
## ── Summary ───────────────────────────────────────────────────────────────────
#echo ""
#echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
#echo -e "${BOLD}║       Release Complete ✓         ║${NC}"
#echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
#echo ""
#echo -e "  ${CYAN}Version:${NC}  $VERSION"
#echo -e "  ${CYAN}Folder:${NC}   $RELEASES_DIR"
#echo -e "  ${CYAN}DMG:${NC}      $DMG_NAME"
#echo -e "  ${CYAN}Zip:${NC}      $ZIP_NAME"
#[ -f "$APPCAST_PATH" ] && echo -e "  ${CYAN}Appcast:${NC}  appcast.xml"
#echo ""
#
#open "$RELEASES_DIR"
#}


#
##!/bin/bash
#set -e
#
## ── Colors ────────────────────────────────────────────────────────────────────
#RED='\033[0;31m'
#GREEN='\033[0;32m'
#YELLOW='\033[1;33m'
#CYAN='\033[0;36m'
#BOLD='\033[1m'
#NC='\033[0m'
#
#log()   { echo -e "${CYAN}▶ $1${NC}"; }
#ok()    { echo -e "${GREEN}✓ $1${NC}"; }
#warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
#error() { echo -e "${RED}✗ $1${NC}"; exit 1; }
#
#echo ""
#echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
#echo -e "${BOLD}║     DevDebug Release Builder     ║${NC}"
#echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
#echo ""
#
## ── Config ────────────────────────────────────────────────────────────────────
#DESKTOP="$HOME/Desktop"
#APP_NAME="DevDebug"
#
#release_dev_debug_app() {
## Find the most recently modified folder on Desktop starting with "DevDebug"
##EXPORT_FOLDER=$(find "$DESKTOP" -maxdepth 1 -type d -name "$APP_NAME*" \
##  ! -name "releases" \
##  -exec stat -f "%m %N" {} \; 2>/dev/null \
##  | sort -rn \
##  | head -1 \
##  | awk '{print $2}')
##
##if [ -z "$EXPORT_FOLDER" ]; then
##  error "No folder starting with '$APP_NAME' found on Desktop — export your archive first"
##fi
##
### Find DevDebug.app inside that folder
##APP_PATH=$(find "$EXPORT_FOLDER" -maxdepth 2 -name "$APP_NAME.app" -type d | head -1)
#APP_PATH="$DESKTOP/DevDebug/$APP_NAME.app"
#
#if [ -z "$APP_PATH" ]; then
#  error "Could not find $APP_NAME.app inside $EXPORT_FOLDER"
#fi
#
#log "Found export folder: $(basename "$EXPORT_FOLDER")"
#ok "Found app: $APP_PATH"
#
## Auto-discover generate_appcast from DerivedData
#SPARKLE_GENERATE_APPCAST=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
#  -path "*/sparkle/Sparkle/bin/generate_appcast" 2>/dev/null | head -1)
#
## ── Prompt for version ────────────────────────────────────────────────────────
#echo ""
#echo -e "${BOLD}Enter release version (e.g. 1.2.0):${NC}"
#read -r VERSION
#
#if [[ -z "$VERSION" ]]; then
#  error "Version cannot be empty"
#fi
#
#echo ""
#log "Building release v$VERSION"
#
## ── Output paths ──────────────────────────────────────────────────────────────
#RELEASES_DIR="$DESKTOP/releases/$VERSION"
#DMG_NAME="DevDebug-$VERSION.dmg"
#ZIP_NAME="DevDebug-$VERSION.zip"
#DMG_PATH="$RELEASES_DIR/$DMG_NAME"
#ZIP_PATH="$RELEASES_DIR/$ZIP_NAME"
#APPCAST_PATH="$RELEASES_DIR/appcast.xml"
#
#mkdir -p "$RELEASES_DIR"
#ok "Created $RELEASES_DIR"
#
## ── Sign node binary ──────────────────────────────────────────────────────────
#log "Signing embedded node binary..."
#NODE_BIN="$APP_PATH/Contents/Resources/devdebug-server-arm64"
#
#if [ -f "$NODE_BIN" ]; then
#  codesign --force --sign - "$NODE_BIN"
#  ok "Signed node binary"
#else
#  warn "Node binary not found at $NODE_BIN — skipping"
#fi
#
## ── Deep sign the app ─────────────────────────────────────────────────────────
#log "Deep signing $APP_NAME.app..."
#codesign --force --deep --sign - "$APP_PATH"
#ok "App signed"
#
## ── Create DMG ────────────────────────────────────────────────────────────────
#log "Creating DMG..."
#hdiutil create \
#  -volname "$APP_NAME" \
#  -srcfolder "$APP_PATH" \
#  -ov \
#  -format UDZO \
#  "$DMG_PATH"
#ok "Created $DMG_NAME"
#
## ── Generate appcast ──────────────────────────────────────────────────────────
#log "Generating appcast with Sparkle signature..."
#
#if [ -n "$SPARKLE_GENERATE_APPCAST" ] && [ -f "$SPARKLE_GENERATE_APPCAST" ]; then
#  ok "Found generate_appcast at: $SPARKLE_GENERATE_APPCAST"
#  "$SPARKLE_GENERATE_APPCAST" \
#    --download-url-prefix "https://yourname.github.io/DevDebug/releases/$VERSION/" \
#    --output-path "$APPCAST_PATH" \
#    "$RELEASES_DIR"
#  ok "Appcast generated"
#else
#  warn "generate_appcast not found — skipping appcast"
#  warn "Build the project with Sparkle added at least once to generate it"
#fi
#
## ── Create zip ────────────────────────────────────────────────────────────────
#log "Creating zip archive..."
#cd "$RELEASES_DIR"
#
#FILES_TO_ZIP="$DMG_NAME"
#[ -f "appcast.xml" ] && FILES_TO_ZIP="$FILES_TO_ZIP appcast.xml"
#
#zip -r "$ZIP_PATH" $FILES_TO_ZIP
#ok "Created $ZIP_NAME"
#
## ── Summary ───────────────────────────────────────────────────────────────────
#echo ""
#echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
#echo -e "${BOLD}║       Release Complete ✓         ║${NC}"
#echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
#echo ""
#echo -e "  ${CYAN}Source:${NC}   $(basename "$EXPORT_FOLDER")"
#echo -e "  ${CYAN}Version:${NC}  $VERSION"
#echo -e "  ${CYAN}Folder:${NC}   $RELEASES_DIR"
#echo -e "  ${CYAN}DMG:${NC}      $DMG_NAME"
#echo -e "  ${CYAN}Zip:${NC}      $ZIP_NAME"
#[ -f "$APPCAST_PATH" ] && echo -e "  ${CYAN}Appcast:${NC}  appcast.xml"
#echo ""
#
#open "$RELEASES_DIR"
#}



#!/bin/bash
set -e

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()   { echo -e "${CYAN}▶ $1${NC}"; }
ok()    { echo -e "${GREEN}✓ $1${NC}"; }
warn()  { echo -e "${YELLOW}⚠ $1${NC}"; }
error() { echo -e "${RED}✗ $1${NC}"; exit 1; }

echo ""
echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}║     DevDebug Release Builder     ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
echo ""

# ── Config ────────────────────────────────────────────────────────────────────
DESKTOP="$HOME/Desktop"
APP_NAME="DevDebug"

# Auto-discover generate_appcast from DerivedData
SPARKLE_GENERATE_APPCAST=$(find "$HOME/Library/Developer/Xcode/DerivedData" \
  -path "*/sparkle/Sparkle/bin/generate_appcast" 2>/dev/null | head -1)

release_dev_debug_app() {
# ── Find latest export folder on Desktop ─────────────────────────────────────
#EXPORT_FOLDER=$(find "$DESKTOP" -maxdepth 1 -type d -name "$APP_NAME*" \
#  ! -name "releases" \
#  -exec stat -f "%m %N" {} \; 2>/dev/null \
#  | sort -rn \
#  | head -1 \
#  | awk '{print $2}')
#
#if [ -z "$EXPORT_FOLDER" ]; then
#  error "No folder starting with '$APP_NAME' found on Desktop — export your archive first"
#fi
#
#APP_PATH=$(find "$EXPORT_FOLDER" -maxdepth 2 -name "$APP_NAME.app" -type d | head -1)

APP_PATH="$DESKTOP/DevDebug/$APP_NAME.app"

if [ -z "$APP_PATH" ]; then
  error "Could not find $APP_NAME.app inside $EXPORT_FOLDER"
fi

log "Found export folder: $(basename "$EXPORT_FOLDER")"
ok "Found app: $APP_PATH"

# ── Prompt for version ────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Enter release version (e.g. 1.2.0):${NC}"
read -r VERSION

if [[ -z "$VERSION" ]]; then
  error "Version cannot be empty"
fi

echo ""
log "Building release v$VERSION"

# ── Output paths ──────────────────────────────────────────────────────────────
RELEASES_DIR="$DESKTOP/releases/$VERSION"
DMG_NAME="DevDebug-$VERSION.dmg"
ZIP_NAME="DevDebug-$VERSION.zip"
DMG_PATH="$RELEASES_DIR/$DMG_NAME"
ZIP_PATH="$RELEASES_DIR/$ZIP_NAME"
APPCAST_PATH="$RELEASES_DIR/appcast.xml"

mkdir -p "$RELEASES_DIR"
ok "Created $RELEASES_DIR"

# ── Sign node binary ──────────────────────────────────────────────────────────
log "Signing embedded node binary..."
NODE_BIN="$APP_PATH/Contents/Resources/devdebug-server-arm64"

if [ -f "$NODE_BIN" ]; then
  codesign --force --sign - "$NODE_BIN"
  ok "Signed node binary"
else
  warn "Node binary not found at $NODE_BIN — skipping"
fi

# ── Deep sign the app ─────────────────────────────────────────────────────────
log "Deep signing $APP_NAME.app..."
codesign --force --deep --sign - "$APP_PATH"
ok "App signed"

# ── Create DMG ────────────────────────────────────────────────────────────────
log "Creating DMG..."
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$APP_PATH" \
  -ov \
  -format UDZO \
  "$DMG_PATH"
ok "Created $DMG_NAME"

# ── Generate appcast ──────────────────────────────────────────────────────────
# generate_appcast scans a folder for .dmg/.zip/.tar.gz and writes appcast.xml
# into that same folder — no --output-path flag supported
log "Generating appcast with Sparkle signature..."

if [ -n "$SPARKLE_GENERATE_APPCAST" ] && [ -f "$SPARKLE_GENERATE_APPCAST" ]; then
  ok "Found generate_appcast at: $SPARKLE_GENERATE_APPCAST"
  "$SPARKLE_GENERATE_APPCAST" \
    --download-url-prefix "https://api.batsirai.dev/uploads/dev-debug/mac-app/releases/$VERSION/" \
    "$RELEASES_DIR"
  # generate_appcast writes appcast.xml directly into $RELEASES_DIR
  if [ -f "$APPCAST_PATH" ]; then
    ok "Appcast generated at $APPCAST_PATH"
  else
    warn "generate_appcast ran but appcast.xml not found — check output above"
  fi
else
  warn "generate_appcast not found — skipping appcast"
  warn "Build the project with Sparkle at least once to generate it"
fi

# ── Create zip (DMG + appcast if present) ────────────────────────────────────
log "Creating zip archive..."
cd "$RELEASES_DIR"

#FILES_TO_ZIP="$DMG_NAME"
#[ -f "appcast.xml" ] && FILES_TO_ZIP="$FILES_TO_ZIP appcast.xml"
FILES_TO_ZIP="$DMG_NAME"

zip -r "$ZIP_PATH" $FILES_TO_ZIP
ok "Created $ZIP_NAME"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}╔══════════════════════════════════╗${NC}"
echo -e "${BOLD}║       Release Complete ✓         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════╝${NC}"
echo ""
echo -e "  ${CYAN}Source:${NC}   $(basename "$EXPORT_FOLDER")"
echo -e "  ${CYAN}Version:${NC}  $VERSION"
echo -e "  ${CYAN}Folder:${NC}   $RELEASES_DIR"
echo -e "  ${CYAN}DMG:${NC}      $DMG_NAME"
echo -e "  ${CYAN}Zip:${NC}      $ZIP_NAME"
[ -f "$APPCAST_PATH" ] && echo -e "  ${CYAN}Appcast:${NC}  appcast.xml"
echo ""

open "$RELEASES_DIR"
}
