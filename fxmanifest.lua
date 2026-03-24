fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'General Shark, RowDog'
description 'Optimized and Improved News Camera'
version '1.0'

dependencies { 'ox_lib', 'ox_inventory', 'ox_target'}

shared_scripts {'@ox_lib/init.lua'}

client_scripts {
	'client.lua'
}
