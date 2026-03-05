#!/usr/bin/env bash

getposandsize() {
	local window_tag=$1
    hyprctl clients -j | jq -r ".[] | select(.tags == [\"$window_tag\"]) | \"\(.size[0]),\(.size[1]),\(.at[0]),\(.at[1])\""
    # outputs hyprctl clients in json format for jq
    # it's all wrapped in an array, so select that array
    # find the object where "tag" = "$window_tag" and select it (vesktop or firefox here)
    # from said object, get width, height, xpos and ypos in "w,h,x,y" format
}

if [[ $(getposandsize "vesktop") != "1463,1023,12,44" || $(getposandsize "firefox") != "1463,1023,444,44" ]]; then   
    hyprctl --batch "\
dispatch resizewindowpixel exact 1463 1023,tag:vesktop;\
dispatch resizewindowpixel exact 1463 1023,tag:firefox;\
dispatch movewindowpixel exact 12 44,tag:vesktop;\
dispatch movewindowpixel exact 444 44,tag:firefox"

else 
    hyprctl --batch "dispatch movewindowpixel -1463 0,tag:vesktop;dispatch movewindowpixel 1463 0,tag:firefox"
    # cool extra functionality that slides both windows to the side if they're 
    # in the right place and the right size already 
fi
