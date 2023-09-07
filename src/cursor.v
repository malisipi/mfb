module mfb

const (
	cursors = [
		create_image_from_embed_file($embed_file("../assets/cursor/default.png")) or { Image{} },
		create_image_from_embed_file($embed_file("../assets/cursor/text.png")) or { Image{} },
		create_image_from_embed_file($embed_file("../assets/cursor/pointer.png")) or { Image{} },
		create_image_from_embed_file($embed_file("../assets/cursor/move.png")) or { Image{} },
	]
)

pub enum Cursor {
	default = 0
	text = 1
	pointer = 2
	move = 3
}

pub fn (mut context Context) set_cursor (cursor Cursor) {
	context.active_cursor = cursors[int(cursor)]
}
