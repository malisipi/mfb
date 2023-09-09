module main

import malisipi.mui
import malisipi.muimpv
import rand

fn change_media (event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData) {
	app_data.user_interaction = true
	filtered_list := if app_data.active_mode == .music {
		app_data.music_list.filtered_list
	} else {
		app_data.videos_list.filtered_list
	}
	new_track := filtered_list[event_details.value.int()]
	load_media(new_track, mut app, mut app_data)
}

fn load_media (new_track string, mut app &mui.Window, mut app_data &AppData) {
	mut video := muimpv.get_video(mut app, "mpv")

	app.get_object_by_id("playing_media")[0]["text"].str = new_track.split("/")#[-1..][0]
	app_data.playing_media = new_track
	video.load_media(new_track)
	video.play()
}

fn next_media(_ mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	filtered_list := if app_data.active_mode == .music {
		app_data.music_list.filtered_list
	} else {
		app_data.videos_list.filtered_list
	}

	if filtered_list.len < 1 { return }

	mut new_track_index := 0

	if !app_data.shuffle {
		track_index := filtered_list.index(app_data.playing_media)
		if track_index == -1 {
			unsafe {
				goto __next_media_shuffle
			}
		} else if track_index + 1 != filtered_list.len {
			new_track_index = track_index + 1
		}
		unsafe {
			goto __next_media_load_media
		}
	}

	__next_media_shuffle:
	new_track_index = rand.int_in_range(0, filtered_list.len) or { 0 }

	__next_media_load_media:
	new_track := filtered_list[new_track_index]
	load_media(new_track, mut app, mut app_data)
}

fn video_event_handler(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := muimpv.get_video(mut app, "mpv")
	
	if event_details.event == "time_pos_update" {
		app.get_object_by_id("time_slider")[0]["val"].num=event_details.value.int()
	} else if event_details.event == "duration_update" {
		new_duration := event_details.value.int()
		app_data.media_duration = new_duration
		if new_duration == 0 {
			if app_data.user_interaction {
				video.load_media(get_stream_url(app_data.playing_media))
			} else {
				play_pause_handler(mui.EventDetails{value:"pause"}, mut app, mut app_data)
				app.get_object_by_id("time_slider")[0]["val"].num = 0
				if app_data.loop == .once {
					play_pause_handler(mui.EventDetails{value:"play"}, mut app, mut app_data)
				} else if app_data.loop == .on {
					next_media(event_details, mut app, mut app_data)
				}
			}
		} else {
			play_pause_handler(mui.EventDetails{value:"play"}, mut app, mut app_data)
			if app_data.user_interaction {
				 app_data.user_interaction = false
			}
		}
		app.get_object_by_id("time_slider")[0]["vlMax"].num=new_duration
	}
}

fn get_stream_url (url string) string {
	if !url.starts_with("@net/") {
		return url
	}
	return parse_net_link(url)
}

fn play_pause_handler(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := muimpv.get_video(mut app, "mpv")
	if event_details.value == "pause" || (event_details.value == "true" && app_data.is_playing) { // Trigger pause
		app_data.is_playing = false
		change_icon(mut app, "play", "control_play")
		video.pause()
	} else if event_details.value == "play" || (event_details.value == "true" && !app_data.is_playing)  { // Trigger continue
		app_data.is_playing = true
		change_icon(mut app, "pause", "control_play")
		if app_data.media_duration == 0 {
			video.load_media(get_stream_url(app_data.playing_media))
		}
		video.play()
	}
}

fn seek_time(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := muimpv.get_video(mut app, "mpv")
	if event_details.event == "unclick" {
		video.seek(event_details.value.int())
		play_pause_handler(mui.EventDetails{value:"play"}, mut app, mut app_data)
	} else if event_details.event == "click" {
		play_pause_handler(mui.EventDetails{value:"pause"}, mut app, mut app_data)
	}
}

fn init_fn(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := muimpv.get_video(mut app, "mpv")
	video.init(mut app)
}

fn change_loop (event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	if app_data.loop == .off {
		// loop once
		change_icon(mut app, "loop_once", "control_loop")
		app_data.loop = .once
	} else if app_data.loop == .once {
		// loop on
		change_icon(mut app, "loop_on", "control_loop")
		app_data.loop = .on
	} else {
		// loop off
		change_icon(mut app, "loop_off", "control_loop")
		app_data.loop = .off
	}
}

fn change_shuffle (event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	if app_data.shuffle {
		// shuffle off
		change_icon(mut app, "shuffle_off", "control_shuffle")
	} else { 
		// shuffle on
		change_icon(mut app, "shuffle_on", "control_shuffle")
	}
	app_data.shuffle=!app_data.shuffle
}

fn change_mode(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	mut video := app.get_object_by_id("mpv")[0]
	mut playlist := app.get_object_by_id("playlist")[0]
	mut playlist_filter := app.get_object_by_id("playlist_filter")[0]
	mut fullscreen_button := app.get_object_by_id("control_fullscreen")[0]
	if event_details.value == "true" {
		video["hi"].bol = false
		fullscreen_button["hi"].bol = false
		playlist["w_raw"].str = "370"
		playlist["x_raw"].str = "100%x -430"
		playlist_filter["w_raw"].str = "400"
		change_icon(mut app, "online_videos", "control_online_media")
		app_data.active_mode = .videos
	} else {
		video["hi"].bol = true
		fullscreen_button["hi"].bol = true
		playlist["w_raw"].str = "100%x -90"
		playlist["x_raw"].str = "30"
		playlist_filter["w_raw"].str = "100%x -60"
		change_icon(mut app, "online_music", "control_online_media")
		app_data.active_mode = .music
	}
	filter_object := app.get_object_by_id("playlist_filter")[0]
	unsafe {
		update_filter(mui.EventDetails{value: filter_object["text"].str.replace("\0","") }, mut app, mut app_data)
	}
}

fn toggle_fullscreen(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData) {
	mut video := app.get_object_by_id("mpv")[0]
	mut compact_mode_control_bg := app.get_object_by_id("compact_mode_control_bg")[0]
	if app_data.compact_mode == true {
		change_icon(mut app, "enter_fullscreen", "control_fullscreen")
		video["x_raw"].str = "30"
		video["y_raw"].str = "30"
		video["w_raw"].str = "100%x -460"
		video["h_raw"].str = "100%y -100"
		compact_mode_control_bg["hi"].bol = true
		app_data.compact_mode = false
	} else {
		change_icon(mut app, "leave_fullscreen", "control_fullscreen")
		video["x_raw"].str = "0"
		video["y_raw"].str = "0"
		video["w_raw"].str = "100%x"
		video["h_raw"].str = "100%y -70"
		compact_mode_control_bg["hi"].bol = false
		app_data.compact_mode = true
	}
}

fn update_filter(event_details mui.EventDetails, mut app &mui.Window, mut app_data &AppData){
	path_list := if app_data.active_mode == .music {
		app_data.music_list.path_list
	} else {
		app_data.videos_list.path_list
	}
	filtered_list := path_list.filter(fn [event_details] (path string) bool {
		return path.to_lower().contains(event_details.value.to_lower())
	})
	if app_data.active_mode == .music {
		app_data.music_list.filtered_list = filtered_list
	} else {
		app_data.videos_list.filtered_list = filtered_list
	}
	app.get_object_by_id("playlist")[0]["table"].tbl = make_table(filtered_list)
}
