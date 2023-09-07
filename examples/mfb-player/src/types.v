module main

const (
	music_dir = find_folder("XDG_MUSIC_DIR")
	videos_dir = find_folder("XDG_VIDEOS_DIR")
)

enum PlayingMode as u8 {
	music = 1
	videos = 2
}

struct Playlist {
mut:
	path_list	[]string
	filtered_list	[]string
}

struct AppData {
mut:
	music_list		Playlist
	videos_list		Playlist
	playing_media		string
	media_duration		int
	active_mode		PlayingMode
	is_playing		bool
	compact_mode		bool
}
