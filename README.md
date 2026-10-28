# TCL NXTPAPER A1 Plus Debloat Guide

Oct 27, 2026

Of the 318 packages on this tablet, 68 are rated safe to remove by the Universal Android Debloater Next Generation (UAD-NG) community list. Removal is per-user and fully reversible, with no root required.

## Device

| Field | Value |
| --- | --- |
| Model | TCL NXTPAPER A1 Plus (9445X, product 9445X2\_CA) |
| Codename | Hermes\_12\_2\_Vis (`hermeswifi`, Wi-Fi only) |
| Android | 16 |
| Build | BQ2A.250925.001-BP2A.250605.031.A3 |
| Packages | 318 total; 241 listed in UAD-NG |

How it was audited: `adb shell pm list packages` was matched against UAD-NG's `uad_lists.json`. UAD-NG rates 68 of the listed packages Recommended, 59 Advanced, 74 Expert and 40 Unsafe. No NXTPAPER-specific debloat list was found online.

## Recommended removals

Every package below is rated Recommended by UAD-NG. The bash script removes all of them, including the four Google apps listed; edit its Google apps section to taste.

| Package | Group | What it does |
| --- | --- | --- |
| `com.tct.gdpr` | TCL | Privacy-policy prompts, User Experience Improvement Program |
| `com.tct.retaildemo` | TCL | Store demo mode |
| `com.tcl.android.launcher.hotapp` | TCL | "Hot Apps"; empty but requests internet |
| `com.tcl.android.launcher.a_overlay` | TCL | Bookmark icon overlay |
| `com.jrdcom.Elabel` | TCL | Regulatory label viewer with data collection |
| `com.tcl.token` | TCL | ECID token (secret code 7383243) |
| `com.tct.secretCode` | TCL | Secret-code logging |
| `com.tct.reducesar` | TCL | Hidden SAR mode toggle |
| `com.tct.smart.switchphone` | TCL | Phone-to-phone migration |
| `com.tct.batterywarning` | TCL | Low-battery / temperature popups |
| `android.autoinstalls.config.TCL.PAI` | TCL | Auto-installs OEM apps after reset |
| `com.qualcomm.qti.qms.service.connectionsecurity` | Qualcomm | Telemetry to tls.telemetry.swe.quicinc.com |
| `com.qualcomm.qti.qms.service.trustzoneaccess` | Qualcomm | QMS logging |
| `com.qualcomm.qti.server.qtiwifi` | Qualcomm | Wi-Fi CSI analytics |
| `com.qti.qcc` | Qualcomm | Logging / test framework |
| `com.qti.dcf` | Qualcomm | Bluetooth content broadcast |
| `com.qualcomm.qti.xrvd.service` | Qualcomm | XRVDTest developer service |
| `com.google.android.adservices.api` | Ad framework | Privacy Sandbox ad services |
| `com.google.mainline.adservices` | Ad framework | AdServices mainline module |
| `com.google.android.ondevicepersonalization.services` | Ad framework | On-device ad personalization |
| `com.google.android.federatedcompute` | Ad framework | Federated learning on user data |
| `com.google.android.feedback` | Ad framework | Crash-report feedback |
| `com.google.android.apps.youtube.kids` | Google app | YouTube Kids |
| `com.google.android.apps.kids.home` | Google app | Kids Space |
| `com.google.android.apps.books` | Google app | Play Books |
| `com.google.android.videos` | Google app | Google TV |

Other Google apps UAD-NG rates Recommended (remove only if unused): Gemini (`apps.bard`), YouTube, YouTube Music, Meet (`tachyon`), Google One, Wallet, Photos, Gmail, Drive, Google Home, Maps, Calendar, Calculator, Files by Google.

## Do not remove

UAD-NG rates these Expert or Unsafe; removing them can break the home screen, updates or power management.

| Package | Why keep |
| --- | --- |
| `com.tcl.android.launcher` | Stock home screen |
| `com.tcl.fota.system` | System updates |
| `com.tct.smart.aota` | OTA updates |
| `com.tct.onetouchbooster` | Smart Manager; power-save modes depend on it |
| `com.tcl.ttvs` | TCSCore background service |
| `com.tcl.guard` | TGuard (IO limit, health) |
| `com.tct.aio` | TCT all-in-one config and OTA checks |
| `com.tct.phone` | SIM / phone services |

Also leave alone: anything under `com.android.*` or `vendor.*`, plus `systemui`, `settings`, `com.google.android.gms` and `com.google.android.gsf`.

## TCL packages UAD-NG does not cover

UAD-NG has no entry for 48 TCL packages on this device. Judging by name only (unverified), these look removable:

- `com.tct.news.hd`: news feed
- `com.tcl.userguide`: user manual
- `com.tct.smart.nps`: likely a Net Promoter Score survey
- `com.tcl.healthcare`

Keep `com.tct.smart.stylus`, `com.tcl.nxtpaperkey` and `com.tcl.ai.note.hd` if you use the pen or the NXTPAPER key.

## Script

The script removes all 26 packages in the Recommended removals table. `-k --user 0` keeps the APK on the system partition, so `--restore` or a factory reset brings everything back.

```sh
./tcl-nxtpaper-debloat.sh --dry-run   # list what would be removed
./tcl-nxtpaper-debloat.sh             # remove
./tcl-nxtpaper-debloat.sh --restore   # reinstall all
```

Single package by hand:

```sh
adb shell pm uninstall -k --user 0 <package>       # remove
adb shell cmd package install-existing <package>   # restore
```

TCL's firmware refuses to uninstall some system packages ("User version can not delete system package"), including YouTube Kids and Play Books. The script detects this and runs `pm disable-user --user 0` instead; restore with `adb shell pm enable <package>`.

Result of the run on 2026-10-27: Google TV uninstalled. 24 packages disabled, Kids Space included, because TCL blocks uninstalling them. `com.tct.gdpr` is a protected package that can be neither uninstalled nor disabled over adb, so it is still active.

```bash
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
```

## Sources

- [UAD-NG repository](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation) (package ratings from `resources/assets/uad_lists.json`)
- [UAD-NG FAQ](https://github.com/Universal-Debloater-Alliance/universal-android-debloater-next-generation/wiki/FAQ)
- [Bayton system app database (TCL)](https://sysapps.bayton.org/packages/com.tcl.demopage)
- [Original Universal Android Debloater](https://github.com/0x192/universal-android-debloater)
