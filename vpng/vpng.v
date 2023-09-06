module vpng

import v.embed_file

const png_signature = [u8(0x89), 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]

pub fn read(filename string) ?PngFile {
	return parse_(filename)
}

pub fn read_from_embed_file (file embed_file.EmbedFileData) ?PngFile {
	return parse_from_embed_file_(file)
}
