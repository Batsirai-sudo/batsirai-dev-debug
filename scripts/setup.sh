#!/usr/bin/env bash

install() {
  heading "Installation"

  # PHP loader
  step "Checking PHP loader"

  if php_loader_installed; then
    ok "PHP auto_prepend_file loader already configured"
  else
    add "Installing PHP auto_prepend_file loader"

    if install_php_loader; then
      ok "PHP loader installed successfully"
    else
      warn "PHP loader installation had issues"
    fi
  fi

  echo ""

  # MU-Plugin for Local WordPress sites
  if [[ "$(uname)" == "Darwin" ]]; then
    step "Checking Local WordPress sites"

    if confirm "Install mu-plugin for Local WordPress sites?" "n"; then
      install_mu_plugin
    else
      info "Skipping mu-plugin installation"
    fi

    echo ""
  fi

  # macOS app
  if [[ "$(uname)" == "Darwin" ]]; then
    step "Checking macOS app"

    if is_app_installed; then
      ok "$APP_NAME already installed"
    else
      add "Installing $APP_NAME"

      if install_swift_dmg; then
        ok "$APP_NAME installed successfully"
      else
        warn "App installation had issues"
      fi
    fi
  fi

  success "Installation complete!"

  echo "Next steps:"
  list_item "Test in code: ${BOLD}\\dev_debug('Hello!');${NC}"
  list_item "Test in code: ${BOLD}\\dev_dump('Hello!');${NC}"
  list_item "View logs in the $APP_NAME app"
  echo ""
}

uninstall() {
  heading "Uninstallation"

  if ! confirm "Are you sure you want to uninstall $PACKAGE?" "n"; then
    info "Uninstall cancelled"
    return 0
  fi


  step "Removing PHP loader"
  uninstall_php_loader

  echo ""

  echo ""

  # MU-Plugin uninstall
  if [[ "$(uname)" == "Darwin" ]]; then
    step "Checking Local WordPress mu-plugins"

    uninstall_mu_plugin

    info "Removed mu-plugin from Local WordPress sites?"

    echo ""
  fi

  step "Removing macOS app"
  uninstall_swift_dmg

  success "Uninstallation complete!"
}

reinstall() {
  heading "Reinstallation"

  if ! confirm "This will uninstall and reinstall $PACKAGE. Continue?" "y"; then
    info "Reinstall cancelled"
    return 0
  fi

  echo ""
  uninstall
  echo ""
  install
}

is_package_installed() {
  composer global show "$PACKAGE" >/dev/null 2>&1
}

php_loader_installed() {
  [[ -n "$PHP_INI_DIR" && -f "$PHP_INI_FILE" ]]
}

is_app_installed() {
  [[ -d "$APP_INSTALL_DIR/$APP_NAME" ]]
}
