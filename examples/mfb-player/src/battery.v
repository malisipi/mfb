module main

import os

fn get_battery_percent () int {
	return (os.read_file("/sys/class/power_supply/BAT0/capacity") or { "100" }).int()
}
