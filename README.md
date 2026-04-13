# shark-newscam
A new and improved version of the classic news camera! Equip the item, use /editnews, and you're ready to go!

## LICENSE
This work is licensed under <a href="https://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International</a><img src="https://mirrors.creativecommons.org/presskit/icons/cc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/by.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;"><img src="https://mirrors.creativecommons.org/presskit/icons/nc.svg" alt="" style="max-width: 1em;max-height:1em;margin-left: .2em;">

## Dependencies:
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)

## Exports
'editnews' - Opens the menu to edit the news header

## Install
Ensure ox_lib and ox_inventory prior

Add the following to your data/items.lua in ox_inventory

	["newscam"] = {
		label = "News Camera",
		weight = 100,
		stack = false,
		close = true,
		consume = 0,
		description = "A camera for the news",
		client = {
			event = 'shark-newscam:toggleCam'
		}
	},

	["newsbmic"] = {
		label = "Boom Microphone",
		weight = 100,
		stack = false,
		close = true,
		description = "A Useable BoomMic",
		client = {
			event = 'shark-newscam:togglebmic'
		}
	},

	["newsmic"] = {
		label = "News Microphone",
		weight = 100,
		stack = false,
		close = true,
		description = "A microphone for the news",
		client = {
			event = 'shark-newscam:togglemic'
		}
	},



## Credits
RowDog created the original script this is based on, and his work is foundational for this. Wouldn't have been possible without his original version https://forum.cfx.re/t/release-weazel-news-camera-and-mic-updated/116118

	
[Support - Discord](https://discord.gg/mFnNTV2Zce)
