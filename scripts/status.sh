#!/usr/bin/env bash

# Table drawing functions
draw_line() {
  local width=$1
  printf "├"
  printf "─%.0s" $(seq 1 $width)
  printf "┤\n"
}

draw_top() {
  local width=$1
  printf "┌"
  printf "─%.0s" $(seq 1 $width)
  printf "┐\n"
}

draw_bottom() {
  local width=$1
  printf "└"
  printf "─%.0s" $(seq 1 $width)
  printf "┘\n"
}

table_row() {
  local label="$1"
  local status="$2"
  local detail="$3"

  printf "│ %-20s │ %-35s │ %-55s │\n" "$label" "$status" "$detail"
}

table_header() {
  local title="$1"
  printf "│ %-108s │\n" "$(echo -e "${BOLD}${BLUE}$title${NC}")"
}

show_status() {
  local table_width=95

  heading "Installation Status Report"

  # Draw table top
  draw_top $table_width

  # ============================================================
  # COMPOSER PACKAGE SECTION
  # ============================================================
  table_header "COMPOSER PACKAGE"
  draw_line $table_width

  if composer global show "$PACKAGE" >/dev/null 2>&1; then
    local version=$(composer global show "$PACKAGE" 2>/dev/null | awk '/versions/ {print $NF}')
    table_row "Package" "$(echo -e "${GREEN}✓ Installed${NC}")" "$PACKAGE $version"
  else
    table_row "Package" "$(echo -e "${RED}✗ Not Installed${NC}")" "Run: dev-debug -i"
  fi

  # ============================================================
  # PHP CONFIGURATION SECTION
  # ============================================================
  draw_line $table_width
  table_header "PHP CONFIGURATION"
  draw_line $table_width

  # PHP Binary
  if [[ -n "$PHP_BIN" && -x "$PHP_BIN" ]]; then
    local php_version=$("$PHP_BIN" -v | head -1 | awk '{print $2}')
    table_row "PHP Binary" "$(echo -e "${GREEN}✓ Found${NC}")" "$PHP_BIN ($php_version)"
  else
    table_row "PHP Binary" "$(echo -e "${RED}✗ Not Found${NC}")" ""
  fi

  # PHP INI
  if [[ -f "$PHP_INI_PATH" ]]; then
    table_row "PHP INI" "$(echo -e "${GREEN}✓ Found${NC}")" "$PHP_INI_PATH"
  else
    table_row "PHP INI" "$(echo -e "${YELLOW}⚠ Not Found${NC}")" "$PHP_INI_PATH"
  fi

  # Config Directory
  if [[ -d "$PHP_INI_DIR" ]]; then
    table_row "Config Dir" "$(echo -e "${GREEN}✓ Found${NC}")" "$PHP_INI_DIR"
  else
    table_row "Config Dir" "$(echo -e "${RED}✗ Not Found${NC}")" "$PHP_INI_DIR"
  fi

  # Loader Config
  if [[ -f "$PHP_INI_FILE" ]]; then
    table_row "Loader Config" "$(echo -e "${GREEN}✓ Installed${NC}")" "$(basename "$PHP_INI_FILE")"

    # Check loader file
    local prepend_value=$(grep "auto_prepend_file" "$PHP_INI_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
    if [[ -f "$prepend_value" ]]; then
      table_row "Loader File" "$(echo -e "${GREEN}✓ Exists${NC}")" "$(basename "$prepend_value")"
    else
      table_row "Loader File" "$(echo -e "${RED}✗ Missing${NC}")" "$prepend_value"
    fi
  else
    table_row "Loader Config" "$(echo -e "${RED}✗ Not Found${NC}")" "Run: dev-debug -i"
    table_row "Loader File" "$(echo -e "${DIM}— N/A${NC}")" ""
  fi


# Show value inside your loader file
if [[ -f "$PHP_INI_FILE" ]]; then
  local main_value=$(grep "auto_prepend_file" "$PHP_INI_FILE" 2>/dev/null | cut -d'=' -f2 | tr -d ' "')

  if [[ -z "$main_value" ]]; then
    main_display="(empty)"
  else
    main_display="$main_value"
  fi

  table_row "Loader Value" "$(echo -e "${CYAN}Main${NC}")" "$main_display"
fi


  # ============================================================
  # AUTO_PREPEND_FILE DETAILS
  # ============================================================

  local conflict_count=0

  # Get all matches except the main loader file
  local matches=$(grep -r "auto_prepend_file" "$PHP_INI_DIR" 2>/dev/null | grep -v "$PHP_INI_FILE")

  if [[ -n "$matches" ]]; then
    echo "$matches" | while IFS=: read -r file line; do
      local value=$(echo "$line" | cut -d'=' -f2 | tr -d ' "' )

      # Normalize empty
      if [[ -z "$value" ]]; then
        display_value="( empty )"
      else
        display_value="$value"
        ((conflict_count++))
      fi

      table_row "auto_prepend_file" "$display_value"  "$file"
    done
  fi




# Count only NON-empty values (excluding main file)
local conflicts=$(grep -r "auto_prepend_file" "$PHP_INI_DIR" 2>/dev/null \
  | grep -v "$PHP_INI_FILE" \
  | awk -F'=' '{gsub(/[ "]/,"",$2); if ($2 != "") print}' \
  | wc -l | xargs)

if [[ "$conflicts" -gt 0 ]]; then
  table_row "Config Conflicts" "$(echo -e "${YELLOW}⚠ Found${NC}")" "$conflicts conflict(s) with value"
else
  table_row "Config Conflicts" "$(echo -e "${GREEN}✓ None${NC}")" ""
fi






#  # Check for conflicts
#  local conflicts=$(grep -r "auto_prepend_file" "$PHP_INI_DIR" 2>/dev/null | grep -v "$PHP_INI_FILE" | wc -l | xargs)
#  if [[ "$conflicts" -gt 0 ]]; then
#    table_row "Config Conflicts" "$(echo -e "${YELLOW}⚠ Found${NC}")" "$conflicts potential conflict(s)"
#  else
#    table_row "Config Conflicts" "$(echo -e "${GREEN}✓ None${NC}")" ""
#  fi

  # ============================================================
  # LOCAL WORDPRESS SITES SECTION
  # ============================================================
  draw_line $table_width
  table_header "LOCAL WORDPRESS SITES"
  draw_line $table_width

  if find_local_sites; then
    table_row "Sites Found" "$(echo -e "${GREEN}✓ ${#LOCAL_SITE_NAMES[@]} site(s)${NC}")" "~/Local Sites/"

    local installed_count=0
    local not_installed_count=0

    # Count installations
    for i in "${!LOCAL_SITE_NAMES[@]}"; do
      if is_mu_plugin_installed "${LOCAL_SITE_PATHS[$i]}"; then
        ((installed_count++))
      else
        ((not_installed_count++))
      fi
    done

    if [[ $installed_count -gt 0 ]]; then
      table_row "MU-Plugin Installed" "$(echo -e "${GREEN}✓ $installed_count site(s)${NC}")" ""
    else
      table_row "MU-Plugin Installed" "$(echo -e "${DIM}— None${NC}")" ""
    fi

    if [[ $not_installed_count -gt 0 ]]; then
      table_row "Not Installed" "$(echo -e "${YELLOW}⚠ $not_installed_count site(s)${NC}")" "Run: dev-debug --mu-install"
    fi

  else
    table_row "Sites Found" "$(echo -e "${DIM}— None${NC}")" "No Local WordPress sites found"
    table_row "MU-Plugin" "$(echo -e "${DIM}— N/A${NC}")" ""
  fi

  # ============================================================
  # MACOS APP SECTION
  # ============================================================
  if [[ "$(uname)" == "Darwin" ]]; then
    draw_line $table_width
    table_header "MACOS APPLICATION"
    draw_line $table_width

    # DMG File
    if [[ -f "$DMG_PATH" ]]; then
      table_row "DMG File" "$(echo -e "${GREEN}✓ Found${NC}")" "$(basename "$DMG_PATH")"
    else
      table_row "DMG File" "$(echo -e "${YELLOW}⚠ Not Found${NC}")" "$(basename "$DMG_PATH")"
    fi

    # Installed App
    if [[ -d "$APP_INSTALL_DIR/$APP_NAME" ]]; then
      local app_version=$(defaults read "$APP_INSTALL_DIR/$APP_NAME/Contents/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "unknown")
      table_row "App Installed" "$(echo -e "${GREEN}✓ Installed${NC}")" "$APP_NAME ($app_version)"

      # Check if running
      if pgrep -f "$APP_NAME" >/dev/null 2>&1; then
        table_row "App Status" "$(echo -e "${GREEN}${BOLD}✓ RUNNING${NC}")   " "Process active"
      else
        table_row "App Status" "$(echo -e "${DIM}— Stopped${NC}")" "Not currently running"
      fi
    else
      table_row "App Installed" "$(echo -e "${RED}✗ Not Installed${NC}")" "Run: dev-debug -i"
      table_row "App Status" "$(echo -e "${DIM}— N/A${NC}")" ""
    fi
  fi

  # ============================================================
  # SUMMARY
  # ============================================================
  draw_line $table_width
  table_header "SYSTEM HEALTH"
  draw_line $table_width

  # Calculate overall health
  local total_checks=0
  local passed_checks=0

  # Critical checks
  composer global show "$PACKAGE" >/dev/null 2>&1 && ((passed_checks++)); ((total_checks++))
  [[ -f "$PHP_INI_FILE" ]] && ((passed_checks++)); ((total_checks++))
  [[ -n "$PHP_BIN" && -x "$PHP_BIN" ]] && ((passed_checks++)); ((total_checks++))

  local health_percent=$((passed_checks * 100 / total_checks))
  local health_status=""
  local health_color=""

  if [[ $health_percent -eq 100 ]]; then
    health_status="EXCELLENT"
    health_color="${GREEN}${BOLD}"
  elif [[ $health_percent -ge 75 ]]; then
    health_status="GOOD"
    health_color="${GREEN}"
  elif [[ $health_percent -ge 50 ]]; then
    health_status="FAIR"
    health_color="${YELLOW}"
  else
    health_status="POOR"
    health_color="${RED}${BOLD}"
  fi

  table_row "Overall Health" "$(echo -e "${health_color}$health_status${NC}")   " "$passed_checks/$total_checks critical checks passed ($health_percent%)"

  # Draw table bottom
  draw_bottom $table_width

  echo ""

  # ============================================================
  # SITE DETAILS TABLE (if sites exist)
  # ============================================================
  if find_local_sites && [[ ${#LOCAL_SITE_NAMES[@]} -gt 0 ]]; then
    echo -e "${BOLD}${BLUE}Local WordPress Sites Details${NC}"
    echo ""

    local site_table_width=95
    draw_top $site_table_width
    printf "│ %-3s │ %-25s │ %-20s │ %-36s │\n" "#" "Site Name" "Status" "Path"
    draw_line $site_table_width

    for i in "${!LOCAL_SITE_NAMES[@]}"; do
      local site_name="${LOCAL_SITE_NAMES[$i]}"
      local wp_content="${LOCAL_SITE_PATHS[$i]}"
      local status=""
      local path_display="$(basename "$(dirname "$(dirname "$(dirname "$wp_content")")")")/.../wp-content"

      if is_mu_plugin_installed "$wp_content"; then
        status="$(echo -e "${GREEN}✓ Installed${NC}         ")"
      else
        status="$(echo -e "${DIM}— Not Installed${NC}")"
      fi

      printf "│ %-3s │ %-25s │ %-30s │ %-36s │\n" "$((i+1))" "$site_name" "$status" "$path_display"
    done

    draw_bottom $site_table_width
    echo ""
  fi

  # ============================================================
  # QUICK ACTIONS
  # ============================================================
  echo -e "${BOLD}${BLUE}Quick Actions${NC}"
  echo ""
  echo -e "  ${GREEN}►${NC} Install/Update:        ${BOLD}dev-debug -i${NC}"
  echo -e "  ${CYAN}►${NC} Manage MU-Plugins:     ${BOLD}dev-debug --mu-install${NC}"
  echo -e "  ${RED}►${NC} Full Uninstall:        ${BOLD}dev-debug -u${NC}"
  echo -e "  ${MAGENTA}►${NC} View This Status:      ${BOLD}dev-debug --status${NC}"
  echo ""
}

