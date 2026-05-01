fx_version 'cerulean'
game 'gta5'

author 'CoreForge'
name 'Core-Crutches'
description 'Light Weight Crutch System - https://github.com/Core-Forge-5/core-crutches'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua'
}

client_scripts {
    "client/cl_crutch.lua",
    "client/cl_knockout.lua",
}

server_scripts {
    "server/sv_crutch.lua",
}
