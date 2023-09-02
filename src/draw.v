module mfb

import math
import gx

[direct_array_access]
pub fn (mut context Context) draw_rect_filled (x f32, y f32, w f32, h f32, c gx.Color) {
	for py in 0..int(h){
		for px in 0..int(w){
			pos := u64((context.width_extended*(int(y)+py)+int(x)+px)*4)
			context.draw_to_pos(pos, c)
		}
	}
}

[direct_array_access]
pub fn (mut context Context) draw_rect_empty (x f32, y f32, w f32, h f32, c gx.Color) {
	context.draw_line(x, y, x+w, y, c)
	context.draw_line(x, y, x, y+h, c)
	context.draw_line(x+w, y, x+w, y+h, c)
	context.draw_line(x, y+h, x+w, y+h, c)
}

[direct_array_access]
pub fn (mut context Context) draw_line (x1 f32, y1 f32, x2 f32, y2 f32, c gx.Color) {
	width := math.abs(x1-x2)
	height := math.abs(y1-y2)

	if width > height {
		xs := math.min(x1, x2)
		ys := if xs==x1 { y1 } else { y2 }
		ye := if xs!=x1 { y1 } else { y2 }
		
		for x:=0; x < width; x++ {
			context.draw_pixel(xs+x, ys+(ye-ys)*x/width, c)
		}
	} else {
		ys := math.min(y1, y2)
		xs := if ys==y1 { x1 } else { x2 }
		xe := if ys!=y1 { x1 } else { x2 }
		
		for y:=0; y < height; y++ {
			context.draw_pixel(xs+(xe-xs)*y/height, ys+y, c)
		}
	}
}

[direct_array_access]
fn collect_points (x1 f32, y1 f32, x2 f32, y2 f32) [][]f32 {
	// Based on draw_line algorithm
	width := math.abs(x1-x2)
	height := math.abs(y1-y2)
	mut points := [][]f32{} // new

	if width > height {
		xs := math.min(x1, x2)
		ys := if xs==x1 { y1 } else { y2 }
		ye := if xs!=x1 { y1 } else { y2 }
		
		for x:=0; x < width; x++ {
			points << [xs+x, ys+(ye-ys)*x/width] // inserts
		}
	} else {
		ys := math.min(y1, y2)
		xs := if ys==y1 { x1 } else { x2 }
		xe := if ys!=y1 { x1 } else { x2 }
		
		for y:=0; y < height; y++ {
			points << [xs+(xe-xs)*y/height, ys+y] // inserts
		}
	}

	return points // new
}

[direct_array_access]
pub fn (mut context Context) draw_triangle_filled (x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, c gx.Color) {
	// TODO: Reimplement it later
	for points in collect_points(x2,y2,x3,y3){
		context.draw_line(x1, y1, points[0], points[1], c)
	}
}

[direct_array_access]
pub fn (mut context Context) draw_triangle_empty (x1 f32, y1 f32, x2 f32, y2 f32, x3 f32, y3 f32, c gx.Color) {
	context.draw_line(x1, y1, x2, y2, c)
	context.draw_line(x1, y1, x3, y3, c)
	context.draw_line(x3, y3, x2, y2, c)
}

[direct_array_access]
pub fn (mut context Context) draw_pixel (x f32, y f32, c gx.Color) {
	pos := u64((context.width_extended*int(y)+int(x))*4)
	context.draw_to_pos(pos, c)
}

[direct_array_access]
pub fn (mut context Context) draw_pixels (points []f32, c gx.Color) {
	point_len := points.len / 2
	for point_index := 0; point_index < point_len ; point_index++ {
		context.draw_pixel(points[point_index*2], points[point_index*2+1], c)
	}
}

[direct_array_access]
fn (mut context Context) draw_to_pos (pos u64, c gx.Color) {
	if pos < 0 || pos > context.max_buffer_size { return }
	if context.allowed_area.width > -1 {
		one_line_pos := pos / 4
		pos_x := int(one_line_pos) % context.width_extended
		if pos_x < context.allowed_area.x || pos_x > context.allowed_area.x + context.allowed_area.width { return }  
		
		pos_y := int(one_line_pos) / context.width_extended
		if pos_y < context.allowed_area.y || pos_y > context.allowed_area.y + context.allowed_area.height { return }
	}
	context.virtualbuffer[pos] = u8(c.b)
	context.virtualbuffer[pos+1] = u8(c.g)
	context.virtualbuffer[pos+2] = u8(c.r)
	context.virtualbuffer[pos+3] = u8(255)
}

[direct_array_access]
pub fn (mut context Context) draw_rounded_rect_filled (x f32, y f32, w f32, h f32, r f32, c gx.Color){
	// TODO: fix it
	context.draw_rect_filled(x,y,w,h,c)
}

[direct_array_access]
pub fn (mut context Context) draw_rounded_rect_empty (x f32, y f32, w f32, h f32, r f32, c gx.Color){
	// TODO: fix it
	context.draw_rect_empty(x,y,w,h,c)
}
