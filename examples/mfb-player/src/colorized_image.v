module main

import malisipi.mui
import malisipi.mfb
import malisipi.mfb.vpng
import v.embed_file
import gx

const (
	def_image_color = gx.Color {
		r: 236
		g: 100
		b: 53
	}
	app_images = {
		"play": load_image_with_color (def_image_color, $embed_file("../assets/play_circle_FILL1_wght500_GRAD0_opsz48.png"))
		"pause": load_image_with_color (def_image_color, $embed_file("../assets/pause_circle_FILL1_wght500_GRAD0_opsz48.png"))
		"loop_off": load_image_with_color (def_image_color, $embed_file("../assets/repeat_FILL1_wght500_GRAD0_opsz48.png"))
		"loop_once": load_image_with_color (def_image_color, $embed_file("../assets/repeat_one_on_FILL1_wght500_GRAD0_opsz48.png"))
		"loop_on": load_image_with_color (def_image_color, $embed_file("../assets/repeat_on_FILL1_wght500_GRAD0_opsz48.png"))
		"shuffle_off": load_image_with_color (def_image_color, $embed_file("../assets/shuffle_FILL1_wght500_GRAD0_opsz48.png"))
		"shuffle_on": load_image_with_color (def_image_color, $embed_file("../assets/shuffle_on_FILL1_wght500_GRAD0_opsz48.png"))
		"online_music": load_image_with_color (def_image_color, $embed_file("../assets/library_music_FILL1_wght500_GRAD0_opsz48.png"))
		"online_videos": load_image_with_color (def_image_color, $embed_file("../assets/video_library_FILL1_wght500_GRAD0_opsz48.png"))
		"enter_fullscreen": load_image_with_color (def_image_color, $embed_file("../assets/fullscreen_FILL1_wght500_GRAD0_opsz48.png"))
		"leave_fullscreen": load_image_with_color (def_image_color, $embed_file("../assets/fullscreen_exit_FILL1_wght500_GRAD0_opsz48.png"))
	}
)

fn load_image_with_color (image_color gx.Color, raw_image embed_file.EmbedFileData) &mfb.Image {
	mut image := vpng.read_from_embed_file(raw_image) or { return &mfb.Image{} }
	for mut pixel in image.pixels {
		pixel = vpng.Pixel {
			red: image_color.r
			green: image_color.g
			blue: image_color.b
			alpha: pixel.alpha
		}
	}
	return &image
}

fn new_colorized_icon (mut app &mui.Window, icon string, args mui.Widget){
	app.image(args)
	change_icon(mut app, icon, args.id)
}

fn change_icon(mut app &mui.Window, icon string, id string){
	app.get_object_by_id(id)[0]["image"].img = app_images[icon] or {&mfb.Image{}}
}
