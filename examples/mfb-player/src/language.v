module main

struct LanguagePack {
	nothing_playing	string = "Nothing is playing"
	filter_media	string = "Filter the Media"
	videos			string = "Videos"
	music			string = "Music"
	media_title		string = "Title of Media"
}

const (
	language_pack = load_language_pack()
)

fn load_language_pack () LanguagePack {
	$if turkish? {
		return LanguagePack {
			nothing_playing: "Medya oynatılmıyor"
			filter_media: "Medyayı filtrele"
			videos: "Videolar"
			music: "Müzik"
			media_title: "Medyanın Başlığı"
		}
	} $else $if german? {
		return LanguagePack {
			nothing_playing: "Es wird nichts abgespielt"
			filter_media: "Filtern Sie die Medien"
			videos: "Videos"
			music: "Musik"
			media_title: "Titel des Mediums"
		}
	} $else $if kurdish? {
		return LanguagePack {
			nothing_playing: "Tiştek nayê lîstin"
			filter_media: "Parzûna Medyayê bikin"
			videos: "Videos"
			music: "Mûzîk"
			media_title: "Sernavê Medya"
		}
	}

	return LanguagePack{}
}