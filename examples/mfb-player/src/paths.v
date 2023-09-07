module main

import os

fn find_folder (folder_code string) string {
	mut path := ""
	path_splitted := os.execute("cat ~/.config/user-dirs.dirs | grep ${folder_code}").output.replace("${folder_code}=\"","")#[0..-2].split("/")
	for path_part in path_splitted {
		if path_part.split("")[0] == "$" {
			path += os.getenv(path_part.replace("$",""))
		} else {
			path += path_part
		}
		path += "/"
	}
	return path
}

fn list_media (folder string) []string {
	mut the_list := []string{}

	os.walk_with_context(folder, &the_list, fn (mut the_list []string, music string) {
		if !os.is_dir(music) {
			the_list << music
		}
	})
	
	return the_list
}

fn make_table (the_list []string) [][]string {
	mut the_table := [][]string{}

	for music in the_list {
		the_table << [ music.split("/")#[-1..][0] ]
	}

	return the_table
}
