#!/bin/sh
# rofi i3 and sway scratchpad menu mode v2.2

tmp_dir="${TMPDIR:-/tmp}"

case "$WAYLAND_DISPLAY" in
	wayland*)
		id_term='con_id'
	;;
	*)
		id_term='id'
	;;
esac

get_scratched() {
	case "$WAYLAND_DISPLAY" in
		wayland*)
			get_tree="$(swaymsg -t get_tree | jq -r ' .. 
				| objects 
				| select(.scratchpad_state? // "none" 
				| . != "none") 
				| [ .id, (.app_id // .window_properties.class), .name ] 
				| @tsv ')"
		;;
		*)
			get_tree="$(i3-msg -t get_tree | jq -r '.nodes[]  
				| .nodes[] 
				| .nodes[] | select(.name=="__i3_scratch") 
				| .floating_nodes[] 
				| .nodes[] 
				| [ .window, .window_properties.class, .name ] 
				| @tsv ')"
		;;
	esac
	count=0
	while IFS="$(printf '\t')" read -r winid app_id data; do
		case "$app_id" in
			org.*)
				icon="$app_id"
			;;
			*)
				icon=$(printf '%s\n' "$app_id" | tr '[:upper:]' '[:lower:]')
			;;
		esac
		[ -z "$data" ] && continue
		printf '%s %s\000icon\037%s\037info\037%s\n' "$app_id -" "$data" "$icon" "$winid"
		count=$((count+1))
		if [ "$count" -ge 2 ] && [ ! -f "$tmp_dir"/rofi_scratchpad ]; then
			touch "$tmp_dir"/rofi_scratchpad
		fi
	done << EOF
${get_tree}
EOF
}

kill_scratched() {
	case "$WAYLAND_DISPLAY" in
		wayland*)
			kill_list="$(swaymsg -t get_tree | jq -r ' .. 
				| objects 
				| select(.scratchpad_state? // "none" 
				| . != "none") 
				| .id ')"
		;;
		*)
			kill_list="$(i3-msg -t get_tree | jq -r ' .. 
				| objects 
				| select(.scratchpad_state? // "none" 
				| . != "none") 
				| .nodes[]
				| .window ')"
		;;
	esac		
	while IFS= read -r id; do
		[ -n "$id" ] && i3-msg "[$id_term=$id] kill" >/dev/null
	done << EOF
${kill_list}
EOF
}

case ${ROFI_RETV:-0} in
	0)
		if command -v jq >/dev/null 2>&1; then
			get_scratched
			if [ -f "$tmp_dir"/rofi_scratchpad ]; then
				printf '%s\n' "[ALL SCRATCHPAD WINDOWS]"
				rm "$tmp_dir"/rofi_scratchpad
			fi
		else
			printf '%s\n' "jq not found"
		fi
	;;
	1)	
	    case "$@" in
			"[ALL SCRATCHPAD WINDOWS]")
				i3-msg "[floating] scratchpad show" >/dev/null
				exit
			;;
			"jq not found")
				exit 1
			;;
			*)
				i3-msg "[$id_term=${ROFI_INFO}] focus" >/dev/null
				exit
	    	;;
	    esac
	;;
	*)
		case "$@" in
		   	"[ALL SCRATCHPAD WINDOWS]")
				kill_scratched
				sleep 0.1
				get_scratched
			;;
			"jq not found")
				exit 1
			;;
			*)
				i3-msg "[$id_term=${ROFI_INFO}] kill" >/dev/null
				sleep 0.1
				get_scratched
		   	;;
		esac	
	;;
esac
