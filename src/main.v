module mfb

import time
import os
import gx
// built-in
import mouse
import keyboard

pub fn new_context(args Config) &Context {
    if !(
    		os.exists("/dev/fb0") && 
    		os.exists("/sys/class/graphics/fb0/virtual_size") &&
    		os.exists("/sys/class/graphics/fb0/stride")
    	){
			panic("Framebuffer output is not supported")
    }

	virtual_size := os.read_file("/sys/class/graphics/fb0/virtual_size") or { panic("Unable to read screen sizes") }
	screen_width := virtual_size.split(",")[0].int()
	screen_height := virtual_size.split(",")[1].int()
	screen_width_ext := int(os.read_file("/sys/class/graphics/fb0/stride") or { panic("Unable to get extended width") }.int()/4)

	mut context := &Context{
		framebuffer:	os.open_file("/dev/fb0","w") or { panic("Unable to open framebuffer device") }
		width:			screen_width
		height:			screen_height
		width_extended:		screen_width_ext
		virtualbuffer:		[]u8{len: screen_width_ext*768*4, cap: screen_width_ext*768*4, init:255}
		max_buffer_size:	u64(screen_width_ext*768*4)
		
		bg_color:		args.bg_color
		user_data:		args.user_data
		frame_fn:		args.frame_fn
		init_fn:		args.init_fn
		event_fn:		args.event_fn
		click_fn:		args.click_fn
		keydown_fn:		args.keydown_fn
		char_fn:		args.char_fn
		move_fn:		args.move_fn
		unclick_fn:		args.unclick_fn
	}
	
	context.mouse_manager = mouse.new_manager(
		screen_width: context.width
		screen_height: context.height
		click_fn: fn [context] (button int, pos_x int, pos_y int) {
			if context.click_fn != unsafe { nil } {
				context.click_fn(f32(pos_x), f32(pos_y), unsafe { MouseButton(button) }, context.user_data)
			}
		},
		move_fn: fn [context] (pos_x int, pos_y int) {
			if context.move_fn != unsafe { nil } {
				context.move_fn(f32(pos_x), f32(pos_y), context.user_data)
			}
		},
		unclick_fn: fn [context] (button int, pos_x int, pos_y int) {
			if context.unclick_fn != unsafe { nil } {
				context.unclick_fn(f32(pos_x), f32(pos_y), unsafe { MouseButton(button) }, context.user_data)
			}
		},
	)
	context.keyboard_manager = keyboard.new_manager(
		keyboard_fn: fn [context] (key keyboard.KeyCode) {
			//println(key)
			if context.event_fn != unsafe { nil } {
				context.event_fn(&Event{
					typ: .key_down
					key_code: key
				}, context.user_data)
			}
			if context.keydown_fn != unsafe { nil } {
				context.keydown_fn(key, unsafe { Modifier(0) }, context.user_data)
			}
			if context.char_fn != unsafe { nil } {
				if key != .escape && key != .enter && key != .backspace && key != .left &&
					key != .right && key != .up && key != .down {
						context.char_fn(u32(key), context.user_data)
				}
			}
		}
	)

	context.set_cursor(.default)

	return context
}

pub fn (mut context Context) begin () {
	context.draw_rect_filled(0, 0, context.width, context.height, context.bg_color)
	context.frame++ // only for compability
}

pub fn (mut context Context) end (){
	context.allowed_area.width = -1
	if context.active_cursor.pixels.len > 0 {
		context.draw_image(context.mouse_manager.pos_x, context.mouse_manager.pos_y, 32, 32, context.active_cursor)	
	} else {
		context.draw_rect_filled(context.mouse_manager.pos_x, context.mouse_manager.pos_y, 8, 8, gx.green) // cursor
	}
	$if show_fps? {
		context.draw_text(0, 0, int(f32(1000) / f32(context.draw_time / time.millisecond)).str() + " FPS", align:.left, vertical_align:.top, color:gx.yellow)
	}
	context.framebuffer.write_to(0, context.virtualbuffer) or {}
}

pub fn (mut context Context) run (){
	if context.init_fn != unsafe { nil } {
		context.init_fn(context.user_data)
	}
	for ;; {
		start_time := time.now()
		context.frame_fn(context.user_data)
		$if !unlimited_fps? {
			frame_end_time := time.now()
			frame_draw_time := frame_end_time - start_time
			time.sleep(int(f32(1000)/context.fps_limit*1000000)*time.nanosecond - frame_draw_time)
		}
		end_time := time.now()
		context.draw_time = end_time - start_time
	}
}

pub fn (mut context Context) window_size () &Size {
	return &Size {
		width: context.width
		height: context.height
	}
}

pub fn (mut context Context) set_bg_color (c gx.Color) {
	context.bg_color = c
}

pub fn (mut context Context) scissor_rect (x int, y int, w int, h int) {
	context.allowed_area = Rect{
		x: x
		y: y
		width: w
		height: h
	}
}

// only for gg compability
pub fn window_size () &Size {
	return &Size {
		width: 800
		height: 600
	}
}

pub fn (mut context Context) quit () {
	keyboard.restore_term()
	exit(0)
}
