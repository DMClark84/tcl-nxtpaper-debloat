#!/usr/bin/env bash
# Debloat TCL NXTPAPER A1 Plus (9445X) via adb. No root; reversible.
# Usage: ./tcl-nxtpaper-debloat.sh            remove
#        ./tcl-nxtpaper-debloat.sh --dry-run  show what would be removed
#        ./tcl-nxtpaper-debloat.sh --restore  reinstall everything listed
set -u

PACKAGES=(
  # TCL bloat / telemetry
  com.tct.gdpr
  com.tct.retaildemo
  com.tcl.android.launcher.hotapp
  com.tcl.android.launcher.a_overlay
  com.jrdcom.Elabel
  com.tcl.token
  com.tct.secretCode
  com.tct.reducesar
  com.tct.smart.switchphone
  com.tct.batterywarning
  android.autoinstalls.config.TCL.PAI
  # Qualcomm telemetry
  com.qualcomm.qti.qms.service.connectionsecurity
  com.qualcomm.qti.qms.service.trustzoneaccess
  com.qualcomm.qti.server.qtiwifi
  com.qti.qcc
  com.qti.dcf
  com.qualcomm.qti.xrvd.service
  # Google ad frameworks
  com.google.android.adservices.api
  com.google.mainline.adservices
  com.google.android.ondevicepersonalization.services
  com.google.android.federatedcompute
  com.google.android.feedback
  # Google apps (edit to taste)
  com.google.android.apps.youtube.kids
  com.google.android.apps.kids.home
  com.google.android.apps.books
  com.google.android.videos
)

mode=${1:-remove}

if ! adb get-state >/dev/null 2>&1; then
  echo "No adb device found." >&2
  exit 1
fi

for pkg in "${PACKAGES[@]}"; do
  case $mode in
    --dry-run) echo "would remove: $pkg" ;;
    --restore)
      printf '%-55s ' "$pkg"
      adb shell pm enable "$pkg" >/dev/null 2>&1
      adb shell cmd package install-existing "$pkg" ;;
    *)
      # TCL blocks uninstalling some system packages; disable those instead
      printf '%-55s ' "$pkg"
      out=$(adb shell pm uninstall -k --user 0 "$pkg")
      case $out in
        *"can not delete"*) adb shell pm disable-user --user 0 "$pkg" ;;
        *) echo "$out" ;;
      esac ;;
  esac
done
