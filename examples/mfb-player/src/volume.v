module main

import malisipi.mui
import os

fn get_system_volume() int {
	return os.execute("pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | grep %").output.replace("%","").int()
}

fn set_system_volume(percent int) {
	os.system("pactl set-sink-volume @DEFAULT_SINK@ ${percent}%")
}

fn change_volume(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	set_system_volume(event_details.value.int())
}
