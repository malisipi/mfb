module mfb

import gx

const (
	mfb__symbols = {
		"invalid": [u8(7),7,7,7,7]
		"1": [u8(2),6,2,2,7]
		"2": [u8(7),1,7,4,7]
		"3": [u8(7),1,3,1,7]
		"4": [u8(5),5,7,1,1]
		"5": [u8(7),4,7,1,7]
		"6": [u8(7),4,7,5,7]
		"7": [u8(7),1,1,1,1]
		"8": [u8(7),5,7,5,7]
		"9": [u8(7),5,7,1,7]
		"0": [u8(7),5,5,5,7]
		"a": [u8(2),5,7,5,5]
		"b": [u8(6),5,6,5,6]
		"c": [u8(3),4,4,4,3]
		"d": [u8(6),5,5,5,6]
		"e": [u8(7),4,6,4,7]
		"f": [u8(7),4,6,4,4]
		"g": [u8(3),4,5,5,3]
		"h": [u8(5),5,7,5,5]
		"i": [u8(7),2,2,2,7]
		"j": [u8(1),1,1,5,7]
		"k": [u8(5),5,6,5,5]
		"l": [u8(4),4,4,4,7]
		"m": [u8(5),7,5,5,5]
		"n": [u8(7),5,5,5,5]
		"o": [u8(7),5,5,5,7]
		"p": [u8(7),5,7,4,4]
		"q": [u8(6),6,6,6,7]
		"r": [u8(6),5,6,5,5]
		"s": [u8(7),4,7,1,7]
		"t": [u8(7),2,2,2,2]
		"u": [u8(5),5,5,5,7]
		"v": [u8(5),5,5,5,6]
		"w": [u8(5),5,5,7,5]
		"x": [u8(5),5,2,5,5]
		"y": [u8(5),5,7,1,7]
		"z": [u8(7),1,7,4,7]
		" ": [u8(0),0,0,0,0]
		":": [u8(0),2,0,2,0]
		"\"":[u8(5),5,0,0,0]
		"'": [u8(2),2,0,0,0]
		"`": [u8(4),2,0,0,0]
		"|": [u8(2),0,2,0,2]
		"%": [u8(5),1,2,4,5]
		"-": [u8(0),0,7,0,0]
		".": [u8(0),0,0,0,2]
		"/": [u8(1),1,2,4,4]
	}
	mfb__available_symbols = mfb__symbols.keys()
)

[direct_array_access]
fn get_text_draw_info(text_ string) [][]u8 {
	text := text_.to_lower()
	mut drawing_chars := [][]u8{}
	text_chars := text.runes()
	for text_char_rune in text_chars {
		text_char := text_char_rune.str() 
		if text_char in mfb__available_symbols {
			drawing_chars << mfb__symbols[text_char]
		} else {
			drawing_chars << mfb__symbols["invalid"]
		}
	}
	return drawing_chars
}

[direct_array_access]
fn get_text_sizes(text string, cfg gx.TextCfg) Size {
	text_len := text.runes().len
	return Size {
		width: (cfg.size * (3+1) / 5) * text_len // (+1) from space
		height: cfg.size  
	}
}

[direct_array_access]
pub fn (mut context Context) draw_text (x int, y int, text string, cfg gx.TextCfg) {
	text_draw_info := get_text_draw_info(text)
	text_size_info := get_text_sizes(text, cfg)
	mut text_pos := [x, y]
	
	if cfg.align == .center {
		text_pos[0] = text_pos[0] - text_size_info.width/2 
	}
	if cfg.align == .right {
		text_pos[0] = text_pos[0] - text_size_info.width 
	}
	
	if cfg.vertical_align == .middle {
		text_pos[1] = text_pos[1] - text_size_info.height/2 
	}
	if cfg.vertical_align == .bottom {
		text_pos[1] = text_pos[1] - text_size_info.height 
	}
	
	repeat_count := (cfg.size / 5)
	
	for chr in text_draw_info {
		for line_index, line in chr {
			cols := [line & 4 == 4, line & 2 == 2, line & 1 == 1]
			for col_index, col in cols {
				if col {
					for rx:=0; rx<repeat_count; rx++ {
						for ry:=0; ry<repeat_count; ry++ {
							context.draw_pixel(text_pos[0]+col_index*repeat_count+ry, text_pos[1]+line_index*repeat_count+rx, cfg.color)
						}
					}
				}
			}
		}
		text_pos[0] += cfg.size * (3+1) / 5 // (+1) from space
	}
}

[direct_array_access]
pub fn (mut context Context) text_size (text string) (int, int) {
	return context.text_width(text), context.text_height(text)
}

[direct_array_access]
pub fn (mut context Context) text_width (text string) int {
	return text.runes().len*16
}

[direct_array_access]
pub fn (mut context Context) text_height (text string) int {
	return 20
}

pub fn (mut context Context) set_text_cfg (cfg gx.TextCfg) {
	context.text_config = cfg
}
