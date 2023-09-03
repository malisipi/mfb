module mfb

import vpng
import gx
import v.embed_file

[direct_array_access]
pub fn (mut context Context) draw_image (x f32, y f32, bw f32, bh f32, img Image) {
	for xbh in 0..int(bh) {
		for xbw in 0..int(bw) {
			index := int(xbh*img.height/bh)*img.width+int(xbw*img.width/bw)
			pixel := img.pixels[index]
			if pixel.alpha < 127 { continue }
			context.draw_pixel(x+xbw, y+xbh, gx.Color{
				r: pixel.red
				g: pixel.green
				b: pixel.blue
			})
		}
	}
}

[direct_array_access]
pub fn (mut context Context) create_image (path string)! Image {
	return vpng.read(path)!
}

[direct_array_access] // extends gg api
pub fn (mut context Context) create_image_from_embed_file (path embed_file.EmbedFileData)! Image {
	return vpng.read_from_embed_file(path)!
}
