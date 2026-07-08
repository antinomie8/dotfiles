#!/usr/bin/env bash

CONFIG_FILE="$HOME/.config/illogical-impulse/config.json"

read_config_value() {
    local json_path="$1"
    jq -r "$json_path // empty" "$CONFIG_FILE" 2>/dev/null
}

CUSTOM_PATH="$(read_config_value ".screenRecord.savePath")"
CUSTOM_FILENAME_FORMAT="$(read_config_value "$.screenRecord.filenameFormat")"

RECORDING_DIR=""

if [[ -n "$CUSTOM_PATH" ]]; then
    RECORDING_DIR="$CUSTOM_PATH"
else
    RECORDING_DIR="$HOME/Videos" # Use default path
fi

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}
getfilename() {
    local filename_format="$CUSTOM_FILENAME_FORMAT"
    local filename=""

    if [[ -n "$filename_format" ]]; then
        filename="$(date +"$filename_format")"
    else
        filename="recording_$(getdate).mp4"
    fi

    if [[ "$filename" != *.mp4 ]]; then
        filename+=".mp4"
    fi

    printf '%s\n' "$filename"
}
getaudiooutput() {
    pactl list sources | grep 'Name' | grep 'monitor' | cut -d ' ' -f2
}
getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

wf_recorder_args() {
    # Record in RGB instead of forcing yuv420p. The default/yuv path can make
    # desktop captures look washed out; libx264rgb preserves the captured colors
    # much more faithfully while still writing an mp4 file.
    printf '%s\0' --codec libx264rgb
}

run_wf_recorder() {
    local args=()
    while IFS= read -r -d '' arg; do
        args+=("$arg")
    done < <(wf_recorder_args)

    wf-recorder "${args[@]}" "$@"
}

mkdir -p "$RECORDING_DIR"
cd "$RECORDING_DIR" || exit

# parse --region <value> without modifying $@ so other flags like --fullscreen still work
ARGS=("$@")
MANUAL_REGION=""
SOUND_FLAG=0
FULLSCREEN_FLAG=0
for ((i=0;i<${#ARGS[@]};i++)); do
    if [[ "${ARGS[i]}" == "--region" ]]; then
        if (( i+1 < ${#ARGS[@]} )); then
            MANUAL_REGION="${ARGS[i+1]}"
        else
            notify-send "Recording cancelled" "No region specified for --region" -a 'Recorder' & disown
            exit 1
        fi
    elif [[ "${ARGS[i]}" == "--sound" ]]; then
        SOUND_FLAG=1
    elif [[ "${ARGS[i]}" == "--fullscreen" ]]; then
        FULLSCREEN_FLAG=1
    fi
done

if pgrep wf-recorder > /dev/null; then
    notify-send "Recording Stopped" "Stopped" -a 'Recorder' &
    pkill wf-recorder &
else
    recording_file="$(getfilename)"

    if [[ $FULLSCREEN_FLAG -eq 1 ]]; then
        notify-send "Starting recording" "$recording_file" -a 'Recorder' & disown
        if [[ $SOUND_FLAG -eq 1 ]]; then
            run_wf_recorder -o "$(getactivemonitor)" -f "./$recording_file" --audio="$(getaudiooutput)"
        else
            run_wf_recorder -o "$(getactivemonitor)" -f "./$recording_file"
        fi
    else
        # If a manual region was provided via --region, use it; otherwise run slurp as before.
        if [[ -n "$MANUAL_REGION" ]]; then
            region="$MANUAL_REGION"
        else
            if ! region="$(slurp 2>&1)"; then
                notify-send "Recording cancelled" "Selection was cancelled" -a 'Recorder' & disown
                exit 1
            fi
        fi

        notify-send "Starting recording" "$recording_file" -a 'Recorder' & disown
        if [[ $SOUND_FLAG -eq 1 ]]; then
            run_wf_recorder -f "./$recording_file" --geometry "$region" --audio="$(getaudiooutput)"
        else
            run_wf_recorder -f "./$recording_file" --geometry "$region"
        fi
    fi
fi
