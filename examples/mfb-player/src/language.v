module main

const (
	language_pack = load_language_pack()
)

fn load_language_pack () map[string]string {
	$if turkish? {
		return {
			"nothing_playing": "Medya oynatılmıyor"
			"filter_media": "Medyayı filtrele"
			"videos": "Videolar"
			"music": "Müzik"
			"media_title": "Medyanın Başlığı"
		}
	}

	return { // default language pack
		"nothing_playing": "Nothing is playing"
		"filter_media": "Filter the Media"
		"videos": "Videos"
		"music": "Music"
		"media_title": "Media title"
	}
}