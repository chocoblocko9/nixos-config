getposandsize() {
	local window_class=$1
    hyprctl clients -j | jq -r ".[] | select(.class == \"$window_class\") | \"\(.size[0]),\(.size[1]),\(.at[0]),\(.at[1])\""
    # outputs hyprctl clients in json format for jq
    # it's all wrapped in an array, so select that array
    # find the object where "class" = "$window_class" and select it (vesktop or firefox here)
    # from said object, get width, height, xpos and ypos in "w,h,x,y" format
}

if [[ $(getposandsize "vesktop") != "1463,1023,12,44" || $(getposandsize "firefox") != "1463,1023,444,44" ]]; then   
    hyprctl --batch "\
dispatch resizewindowpixel exact 1463 1023,class:vesktop;\
dispatch resizewindowpixel exact 1463 1023,class:firefox;\
dispatch movewindowpixel exact 12 44,class:vesktop;\
dispatch movewindowpixel exact 444 44,class:firefox"

else 
    hyprctl --batch "dispatch movewindowpixel -1463 0,class:vesktop;dispatch movewindowpixel 1463 0,class:firefox"
fi