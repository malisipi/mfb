module main

import malisipi.mui
import malisipi.muimpv
import time
import gx

fn main(){
	music_path_list := list_media(music_dir)
	videos_path_list := list_media(videos_dir)
	mut app_data := &AppData{
		music_list: Playlist{
			path_list: music_path_list
			filtered_list: music_path_list
		}
		videos_list: Playlist{
			path_list: videos_path_list
			filtered_list: videos_path_list
		}
		playing_media: ""
		active_mode: .music
	}

	mut app:=mui.create(app_data: app_data, draw_mode:.linux_dark, init_fn: &init_fn)
	muimpv.load_into_app(mut app)

	app.label(id: "music_mode" x: "# 50%x -20", y: 5, width:200, height:20, text_align:2, text:language_pack.music)
	app.switch(id: "mode_changer", x: "50%x -20", y: 5, width: 40, height:20, onchange: change_mode)
	app.label(id: "videos_mode" x: "50%x +20", y: 5, width:200, height:20, text_align:0, text:language_pack.videos)
	app.textbox(id: "playlist_filter", x: "# 30", y: 30, height: 30, width: "100%x -60" placeholder: language_pack.filter_media, onchange:update_filter)
	app.list(id: "playlist", table: make_table(app_data.music_list.filtered_list), x: 30, y: 60, width: "100%x -90", height: "100%y -130", row_height: 40, onchange:change_media)
	app.scrollbar(id: "playlist_scrollbar", x: "# 30", y: 60, width: 30, height: "100%y -130", vertical: true, connected_widget: app.get_object_by_id("playlist")[0])
	app.label(id: "timing" x: "# 10", y: "# 35", width:200, height:20, text: "00:00/00:00", text_align:2)
	app.label(id: "playing_media", x: "20%x", y: "# 40" width: "60%x", height:20, text: language_pack.nothing_playing)
	app.slider(id:"time_slider", x:70, y:"# 10", width:"100%x -80", height:20, onclick:seek_time, onunclick:seek_time, onchange:seek_time, value_map:fn [mut app, app_data] (the_time int) string {
		app.get_object_by_id("timing")[0]["text"].str = "${the_time/60:02}:${the_time%60:02}/${app_data.media_duration/60:02}:${app_data.media_duration%60:02}"
		return ""
	} )
	app.rect(id: "compact_mode_control_bg", x: 0, y: "# 0", width: "100%x", height: "70", background: gx.black  hidden: true)
	
	new_colorized_icon(mut app, "play", id: "control_play", x: 10, y: "# 10", width: 50, height: 50, onclick: play_pause_handler)
	new_colorized_icon(mut app, "loop_off", id: "control_loop", x: 70, y: "# 35", width: 20, height: 20)
	new_colorized_icon(mut app, "shuffle_off", id: "control_shuffle", x: 95, y: "# 35", width: 20, height: 20)
	new_colorized_icon(mut app, "online_music", id: "control_online_media", x: 120, y: "# 35", width: 20, height: 20, onclick: load_online_media)
	new_colorized_icon(mut app, "enter_fullscreen", id: "control_fullscreen", x: 145, y: "# 35", width: 20, height: 20, onclick: toggle_fullscreen, hidden: true)
	app.slider(id:"control_volume", x:170, y:"# 35", width:40, height:20, value_min:0, value:get_system_volume(), value_max:150 onchange:change_volume)
	
	app.label(id: "battery" x: "# 5", y: 5, width:200, height:20, text_align:2, text:"100%")
	battery_updater := fn [mut app] () {
		mut battery := app.get_object_by_id("battery")[0]
		for ;; {
			battery["text"].str = "${get_battery_percent()}%"
			time.sleep(5*time.second)
		}
	}
	go battery_updater()
	
	muimpv.new(mut app, video_event_handler, id:"mpv", x:30, y:30, width:"100%x -460", height:"100%y -100", hidden:true, z_index:9)

	app.run()
}
