getpos() {
	local window_name=$1
	class_line=$(hyprctl clients | grep -n ".*class: ${window_name}" | cut -d':' -f1)
	# Prints hyprctl clients, pipes into grep -n which returns line with the line number appended
	# to it, and pipes that into cut which has the delimiter : so it leaves just the line number.
	
	adjust=$((${class_line} -6))
	# Thankfully hyprctl clients is consistent in its values, and the "at: x y" field is always
	# 6 lines before the "class: x" field. (Might need to fix with updates...)
	
	pos=$(hyprctl clients | sed "${adjust}q;d")
	# Sed uses the line number to only return that exact line number
	
	final=${pos:5}
	# And some final cutting to return just the window position. Cool!
	
	echo ${final}
}

vesktop_x=$(getpos "vesktop" | cut -d',' -f1)
vesktop_y=$(getpos "vesktop" | cut -d',' -f2)
firefox_x=$(getpos "firefox" | cut -d',' -f1)
firefox_y=$(getpos "firefox" | cut -d',' -f2)

#hyprctl "dispatch movewindowpixel $(( 12 - ${vesktop_x})) $(( 44 - ${vesktop_y})),class:vesktop"
#hyprctl "dispatch movewindowpixel $(( 444 - ${firefox_x})) $(( 44 - ${firefox_y})),class:firefox"

# this if statement is a tab broken but it does the functionality, will fix it tomorrow hopefully
if [[ $(getpos "vesktop") != "12,44" || $(getpos "firefox") != "444,44" ]]; then                                                                                               
    hyprctl "dispatch movewindowpixel $(( 12 - ${vesktop_x})) $(( 44 - ${vesktop_y})),class:vesktop"
    hyprctl "dispatch movewindowpixel $(( 444 - ${firefox_x})) $(( 44 - ${firefox_y})),class:firefox"
else 
    hyprctl "dispatch movewindowpixel -1463 0,class:vesktop"
    hyprctl "dispatch movewindowpixel 1463 0,class:firefox"
fi

