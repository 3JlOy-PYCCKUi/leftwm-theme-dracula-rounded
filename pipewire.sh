#!/bin/bash

function check_mic() {
	def_source_id=$(pw-record --list-targets | sed -n 's/^*[[:space:]]*\([[:digit:]]\+\):.*$/\1/p')
	src_line=$(pactl list sources | awk "/Source #${def_source_id}/ {print NR}")
	pactl list sources | sed -n "$(((src_line+8)))p" | cut -d":" -f2 | grep -Eo "no|yes"
}

function main() {
    DEFAULT_SINK_ID=$(pw-play --list-targets | sed -n 's/^*[[:space:]]*\([[:digit:]]\+\):.*$/\1/p')
    VOLUME=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Volume/ s!^[[:space:]]\+Volume:.* \([[:digit:]]\+\)%.*!\1!p" | head -n1)
    IS_OUT_MUTED=$(pactl list sinks | sed -n "/Sink #${DEFAULT_SINK_ID}/,/Mute/ s/Mute: \(yes\)/\1/p")
    IS_MIC_MUTED=$(check_mic)

    action=$1
    if [ "${action}" == "up" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ +5%
    elif [ "${action}" == "down" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ -5%
    elif [ "${action}" == "out-mute" ]; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
    elif [ "${action}" == "mic-mute" ]; then
    	pactl set-source-mute @DEFAULT_SOURCE@ toggle
    else
	if [ "$IS_MIC_MUTED" == "yes" ]; then
		printf " | "
	else
		printf " | "
	fi
        if [ "${IS_OUT_MUTED=}" != "" ]; then
            printf "  MUTED\n"
        else
            printf "  ${VOLUME}"
	    echo "% "
        fi
    fi
}

main "$@"
