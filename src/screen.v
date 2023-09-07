module mfb

import os

fn get_screen_information () ScreenInformation {
	if !(
		os.exists("/dev/fb0") && 
		os.exists("/sys/class/graphics/fb0/virtual_size") &&
		os.exists("/sys/class/graphics/fb0/stride")
	){
			panic("Framebuffer output is not supported")
	}
	
	virtual_size := os.read_file("/sys/class/graphics/fb0/virtual_size") or { panic("Unable to read screen sizes") }
	return ScreenInformation {
		width: virtual_size.split(",")[0].int(),
		height: virtual_size.split(",")[1].int(),
		width_ext: int(os.read_file("/sys/class/graphics/fb0/stride") or { panic("Unable to get extended width") }.int()/4)
	}
}
