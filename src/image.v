module mfb

import vpng
import gx
import v.embed_file

[direct_array_access]
pub fn (mut context Context) draw_image (x f32, y f32, w f32, h f32, img Image) {
	for ic in 0..int(w) {
		for ir in 0..int(h) {
			pixel := img.pixels[int(ir*(f32(img.height)/h)*img.width)+int(ic*(f32(img.width)/w))]
			if pixel.alpha < 127 { continue }
			context.draw_pixel(x+ic, y+ir, gx.Color{
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
