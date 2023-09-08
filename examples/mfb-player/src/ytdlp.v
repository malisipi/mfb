module main

import malisipi.mui
import malisipi.muimpv
import os

fn get_online_media (is_music bool, raw_search string) string {
	search := raw_search.replace("\"","").replace("$","").replace("@","").replace("#","").replace("'","").replace("`","")
	if is_music {
		return os.execute('yt-dlp --get-url -f "bestaudio[ext=m4a]" "ytsearch1:${search}"').output
	} else { // if video
		return os.execute('yt-dlp --get-url -f "[ext=mp4]" "ytsearch1:${search}"').output
	}
}

fn load_online_media (event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := muimpv.get_video(mut app, "mpv")
	async_loader := fn [mut app, mut video, mut app_data] () {
		app.create_dialog(typ:"textbox", title:language_pack.media_title)
		answer := app.wait_and_get_answer()
		if answer == "" { return }
		app_data.user_interaction = true
		stream_url := get_online_media(app_data.active_mode == .music, answer)
		app.get_object_by_id("playing_media")[0]["text"].str = answer
		app_data.playing_media = "@net/"+(app_data.active_mode == .music).str()+"/"+answer.replace("@net/","").replace("/","")
		video.load_media(stream_url)
	}
	go async_loader()
}

fn parse_net_link (url string) string {
	data := url.split("/")
	return get_online_media(data[1] == "1", data[2])
}
