module mouse

import os
import math

pub struct Config {
pub mut:
	screen_width	int = 640
	screen_height	int = 480
	click_fn	fn (int, int, int) = unsafe { nil }
	move_fn		fn (int, int) = unsafe { nil }
	unclick_fn	fn (int, int, int) = unsafe { nil }
}

pub struct Manager {
pub mut:
	mouse		os.File
	pos_x		int = 200
	pos_y		int = 200
	screen_width	int = 640
	screen_height	int = 480
	click_fn	fn (int, int, int) = unsafe { nil }
	move_fn		fn (int, int) = unsafe { nil }
	unclick_fn	fn (int, int, int) = unsafe { nil }
	left_button	bool
	right_button	bool
}

fn (mut manager Manager) controller () {
	for ;; {
		mouse_code := manager.mouse.read_bytes(3)
		if mouse_code[0] == 9 && !manager.left_button {
			manager.left_button = true
			manager.click_fn (
				0,
				manager.pos_x,
				manager.pos_y
			)
		} else if mouse_code[0] == 10 && !manager.right_button {
			manager.right_button = true
			manager.click_fn (
				1,
				manager.pos_x,
				manager.pos_y
			)
		} else if mouse_code[0] == 8 || mouse_code[0] == 11 {
			if manager.left_button {
				manager.unclick_fn (
					0,
					manager.pos_x,
					manager.pos_y
				)
			} else if manager.right_button {
				manager.unclick_fn (
					1,
					manager.pos_x,
					manager.pos_y
				)
			}
			manager.left_button = false
			manager.right_button = false
		}
		
		mut trigger_move_fn := false

		pos_x := if mouse_code[1] < 127 {
			math.min(manager.screen_width, manager.pos_x+mouse_code[1])
		} else {
			math.max(0, manager.pos_x-math.abs(255-mouse_code[1]))
		}

		if pos_x != manager.pos_x {
			manager.pos_x = pos_x
			trigger_move_fn = true
		}
		
		pos_y := if mouse_code[2] < 127 {
			math.max(0, manager.pos_y-mouse_code[2])
		} else {
			math.min(manager.screen_height, manager.pos_y+math.abs(255-mouse_code[2]))
		}

		if pos_y != manager.pos_y {
			manager.pos_y = pos_y
			trigger_move_fn = true
		}

		if trigger_move_fn {
			manager.move_fn (
				manager.pos_x,
				manager.pos_y
			)
		}
	}
}

pub fn new_manager (args Config) &Manager {
	mut manager := &Manager{
		mouse: os.open_file("/dev/input/mice", "r") or { panic("Mouse module was failed") }
		click_fn: args.click_fn
		move_fn: args.move_fn
		unclick_fn: args.unclick_fn
		screen_width: args.screen_width
		screen_height: args.screen_height
	}
	go manager.controller()
	return manager
}
