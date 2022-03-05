fx_version 'adamant'
author 'negbook'
game 'gta5'
lua54 'yes'

files {
	'import',
}

shared_scripts {
    "shared/util.lua"
}

client_scripts {
	'config.lua',
	'client/init.lua',
    'client/tasksync.lua',
    'client/tasksync_once.lua',
	'client/client.lua'
}

server_script "server/server.lua"
files { 
    'html/*',
	"seatbelt/seatbelt.awc",
	"seatbelt/seatbelt.dat54.rel"
}

ui_page 'html/index.html'
data_file "AUDIO_WAVEPACK" "seatbelt"
data_file "AUDIO_SOUNDDATA" "seatbelt/seatbelt.dat"


