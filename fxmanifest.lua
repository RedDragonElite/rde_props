fx_version 'cerulean'
game 'gta5'

author 'RDE| SerpentsByte'
description 'Advanced Prop Management System'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    '@ox_core/lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

dependencies {
    'ox_core',
    'ox_lib',
    'oxmysql',
    'ox_inventory',
    'ox_target',
}

lua54 'yes'