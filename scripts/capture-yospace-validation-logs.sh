#!/usr/bin/env bash
set -euo pipefail

APP_ID="com.bitmovin.player.integrations.yospace.example"
APP_NAME="BitmovinYospacePlayerExample"
WORKSPACE="BitmovinYospacePlayer.xcworkspace"
SCHEME="BitmovinYospacePlayerExample"
DEFAULT_OUTPUT_DIR="build/yospace-validation"
DEFAULT_DERIVED_DATA_DIR="build/yospace-validation-derived-data"
BUILD=true
SUBMISSION=""
OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
DERIVED_DATA_DIR="${DERIVED_DATA_DIR:-$DEFAULT_DERIVED_DATA_DIR}"
SIMULATOR_UDID="${SIMULATOR_UDID:-}"
DEVICE_ID="${DEVICE_ID:-}"

usage() {
  cat <<USAGE
Usage: $0 --submission <vod|dvr-live-direct|all> [--device <identifier>] [--output-dir <dir>] [--skip-build]

Generates the two iOS log files required by one Yospace validation submission.
By default, the script uses a simulator. Set SIMULATOR_UDID to select a specific simulator.
Pass --device (or set DEVICE_ID) to use a connected physical device. Physical-device
builds also require DEVELOPMENT_TEAM to be set to the Apple development team identifier.
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --submission)
      SUBMISSION="${2:-}"
      shift 2
      ;;
    --output-dir)
      OUTPUT_DIR="${2:-}"
      shift 2
      ;;
    --device)
      DEVICE_ID="${2:-}"
      shift 2
      ;;
    --skip-build)
      BUILD=false
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$SUBMISSION" ]]; then
  echo "--submission is required" >&2
  usage >&2
  exit 2
fi

case "$SUBMISSION" in
  vod|dvr-live-direct|all) ;;
  *)
    echo "Unsupported submission: $SUBMISSION" >&2
    usage >&2
    exit 2
    ;;
esac

submissions() {
  if [[ "$SUBMISSION" == "all" ]]; then
    printf '%s\n' vod dvr-live-direct
  else
    printf '%s\n' "$SUBMISSION"
  fi
}

submission_asset() {
  case "$1" in
    vod) echo "VOD" ;;
    dvr-live-direct) echo "DVR_LIVE" ;;
  esac
}

submission_initialization_label() {
  case "$1" in
    vod) echo "N/A" ;;
    dvr-live-direct) echo "DIRECT" ;;
  esac
}

submission_validation_selection() {
  case "$1" in
    vod) echo "VOD" ;;
    dvr-live-direct) echo "DVR Live with direct initialization" ;;
  esac
}

test_case_argument() {
  case "$1" in
    ad_break) echo "AD_BREAK" ;;
    two_sessions) echo "TWO_SESSIONS" ;;
  esac
}

test_case_timeout_seconds() {
  case "$1" in
    ad_break) echo 960 ;;
    two_sessions) echo 420 ;;
  esac
}

timestamp() {
  date -u +"%Y%m%dT%H%M%SZ"
}

commit_sha() {
  git rev-parse --short HEAD 2>/dev/null || echo "unknown"
}

resolve_simulator() {
  if [[ -n "$SIMULATOR_UDID" ]]; then
    return
  fi

  SIMULATOR_UDID="$(
    xcrun simctl list devices available |
      awk -F '[()]' '/iPhone/ && /Booted/ { print $2; exit }'
  )"

  if [[ -z "$SIMULATOR_UDID" ]]; then
    SIMULATOR_UDID="$(
      xcrun simctl list devices available |
        awk -F '[()]' '/iPhone/ && /Shutdown/ { print $2; exit }'
    )"
  fi

  if [[ -z "$SIMULATOR_UDID" ]]; then
    echo "No available iPhone simulator found. Set SIMULATOR_UDID explicitly." >&2
    exit 2
  fi
}

boot_simulator() {
  xcrun simctl boot "$SIMULATOR_UDID" 2>/dev/null || true
  xcrun simctl bootstatus "$SIMULATOR_UDID" -b
}

build_and_install() {
  local app_path

  if [[ -n "$DEVICE_ID" ]]; then
    if [[ -z "${DEVELOPMENT_TEAM:-}" ]]; then
      echo "DEVELOPMENT_TEAM is required for physical-device builds." >&2
      exit 2
    fi

    if [[ "$BUILD" == true ]]; then
      xcodebuild \
        -workspace "$WORKSPACE" \
        -scheme "$SCHEME" \
        -configuration Debug \
        -destination "platform=iOS,id=$DEVICE_ID" \
        -derivedDataPath "$DERIVED_DATA_DIR" \
        -packageAuthorizationProvider netrc \
        -allowProvisioningUpdates \
        "DEVELOPMENT_TEAM=$DEVELOPMENT_TEAM" \
        build
    fi

    app_path="$DERIVED_DATA_DIR/Build/Products/Debug-iphoneos/$APP_NAME.app"
    if [[ ! -d "$app_path" ]]; then
      echo "Built app not found at $app_path. Run without --skip-build first." >&2
      exit 2
    fi

    xcrun devicectl device install app --device "$DEVICE_ID" "$app_path"
    return
  fi

  if [[ "$BUILD" == true ]]; then
    xcodebuild \
      -workspace "$WORKSPACE" \
      -scheme "$SCHEME" \
      -configuration Debug \
      -destination "platform=iOS Simulator,id=$SIMULATOR_UDID" \
      -derivedDataPath "$DERIVED_DATA_DIR" \
      -packageAuthorizationProvider netrc \
      CODE_SIGNING_ALLOWED=NO \
      build
  fi

  app_path="$DERIVED_DATA_DIR/Build/Products/Debug-iphonesimulator/$APP_NAME.app"
  if [[ ! -d "$app_path" ]]; then
    echo "Built app not found at $app_path. Run without --skip-build first." >&2
    exit 2
  fi

  xcrun simctl install "$SIMULATOR_UDID" "$app_path"
}

wait_for_marker() {
  local log_file="$1"
  local timeout_seconds="$2"
  local deadline=$((SECONDS + timeout_seconds))
  local recent_log

  while (( SECONDS < deadline )); do
    recent_log="$(tail -n 2000 "$log_file")"
    if grep -Eq "YospaceValidation.*PASS" <<< "$recent_log"; then
      return 0
    fi
    if grep -Eq "YospaceValidation.*FAIL" <<< "$recent_log"; then
      return 1
    fi
    sleep 2
  done

  echo "$(date '+%Y-%m-%d %H:%M:%S') YospaceValidation FAIL reason=host-timeout" >> "$log_file"
  return 1
}

capture_case() {
  local submission="$1"
  local test_case="$2"
  local run_dir="$3"
  local failed_dir="$4"
  local asset
  local test_case_name
  local timeout_seconds
  local temp_dir
  local temp_log
  local final_log
  local log_pid=""

  cleanup_capture_case() {
    trap - RETURN EXIT
    if [[ -n "$log_pid" ]]; then
      kill "$log_pid" 2>/dev/null || true
      wait "$log_pid" 2>/dev/null || true
      log_pid=""
    fi
    if [[ -z "$DEVICE_ID" ]]; then
      xcrun simctl terminate "$SIMULATOR_UDID" "$APP_ID" >/dev/null 2>&1 || true
    fi
    if [[ -n "${temp_dir:-}" && -d "$temp_dir" ]]; then
      rm -rf "$temp_dir"
      temp_dir=""
    fi
  }

  asset="$(submission_asset "$submission")"
  test_case_name="$(test_case_argument "$test_case")"
  timeout_seconds="$(test_case_timeout_seconds "$test_case")"
  temp_dir="$(mktemp -d "${TMPDIR:-/tmp}/yospace-validation-${submission}-${test_case}.XXXXXX")"
  trap cleanup_capture_case RETURN EXIT
  temp_log="$temp_dir/device.log"
  : > "$temp_log"
  final_log="$run_dir/${submission}_${test_case}.log"

  echo "Capturing $submission / $test_case_name"
  if [[ -n "$DEVICE_ID" ]]; then
    # devicectl forwards variables with the documented DEVICECTL_CHILD_ prefix.
    DEVICECTL_CHILD_BITMOVIN_PLAYER_LICENSE_KEY="${BITMOVIN_PLAYER_LICENSE_KEY:-}" \
      xcrun devicectl device process launch \
      --device "$DEVICE_ID" \
      --terminate-existing \
      --console \
      "$APP_ID" \
      --validation-mode \
      --asset "$asset" \
      --test-case "$test_case_name" > "$temp_log" 2>&1 &
    log_pid="$!"
  else
    xcrun simctl terminate "$SIMULATOR_UDID" "$APP_ID" >/dev/null 2>&1 || true
    xcrun simctl spawn "$SIMULATOR_UDID" log stream \
      --style syslog \
      --level debug \
      --predicate "process == \"$APP_NAME\"" > "$temp_log" 2>&1 &
    log_pid="$!"
    sleep 2

    SIMCTL_CHILD_BITMOVIN_PLAYER_LICENSE_KEY="${BITMOVIN_PLAYER_LICENSE_KEY:-}" \
      xcrun simctl launch "$SIMULATOR_UDID" "$APP_ID" \
      --args \
      --validation-mode \
      --asset "$asset" \
      --test-case "$test_case_name" >/dev/null
  fi

  if wait_for_marker "$temp_log" "$timeout_seconds"; then
    cp "$temp_log" "$final_log"
    echo "Wrote $final_log"
    return 0
  fi

  mkdir -p "$failed_dir"
  cp "$temp_log" "$failed_dir/${submission}_${test_case}.failed.log"
  echo "Validation run failed. Debug log: $failed_dir/${submission}_${test_case}.failed.log" >&2
  return 1
}

write_manifest() {
  local submission="$1"
  local run_dir="$2"

  cat > "$run_dir/${submission}_manifest.txt" <<MANIFEST
Submission: $submission
Yospace validation selection: $(submission_validation_selection "$submission")
Asset argument: $(submission_asset "$submission")
Initialization type: $(submission_initialization_label "$submission")
Commit: $(commit_sha)
Created at: $(timestamp)
Upload files:
- ${submission}_ad_break.log
- ${submission}_two_sessions.log
MANIFEST
}

if [[ -z "$DEVICE_ID" ]]; then
  resolve_simulator
  boot_simulator
fi
build_and_install
mkdir -p "$OUTPUT_DIR"

for submission in $(submissions); do
  run_dir="$OUTPUT_DIR/${submission}-$(timestamp)"
  failed_dir="$run_dir/failed"
  mkdir -p "$run_dir"

  if capture_case "$submission" ad_break "$run_dir" "$failed_dir" &&
    capture_case "$submission" two_sessions "$run_dir" "$failed_dir"; then
    write_manifest "$submission" "$run_dir"
    echo "Upload-ready logs: $run_dir"
  else
    echo "Submission $submission failed; not upload-ready." >&2
    exit 1
  fi
done
