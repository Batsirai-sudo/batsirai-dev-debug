#!/usr/bin/env bash

REPO_NAME="dev-debug"
PACKAGE="batsirai/dev-debug"
PACKAGE_BRANCH="dev-main"

PACKAGE_PATH="$BASE_DIR"
COMPOSER_HOME="$(composer global config home)"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

LOADER_PATH="$ROOT_DIR/global-dev-debug-loader.php"

APP_INSTALL_DIR="/Applications"
APP_NAME="DevDebug.app"
