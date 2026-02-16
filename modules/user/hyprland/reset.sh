getpos() {
	local window_name=$1
	get_class_line=$(hyprctl clients | grep -n ".*class: ${window_name}" | cut -d':' -f1)
	# Prints hyprctl clients, pipes into grep -n which returns line with the line number appended
	# to it, and pipes that into cut which has the delimiter : so it leaves just the line number.
	
	get_pos_line=$((${get_class_line} -6))
	# Thankfully hyprctl clients is consistent in its values, and the "at: x y" field is always
	# 6 lines before the "class: x" field. (Might need to fix with updates...)
	
	pos=$(hyprctl clients | sed "${get_pos_line}q;d")
	# Sed uses the line number to only return that exact line number
	
	cut_pos=${pos:5}
	# And some final cutting to return just the window position. Cool!
	
	echo ${cut_pos}
}

if [[ $(getpos "vesktop") != "12,44" || $(getpos "firefox") != "444,44" ]]; then                                                                                               
    hyprctl "dispatch movewindowpixel exact 12 44,class:vesktop"
    hyprctl "dispatch movewindowpixel exact 444 44,class:firefox"
else 
    hyprctl "dispatch movewindowpixel -1463 0,class:vesktop"
    hyprctl "dispatch movewindowpixel 1463 0,class:firefox"
fi

