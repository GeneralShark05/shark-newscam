# shark-newscam
A new and improved version of the classic news camera! Equip the item, use /editnews, and you're ready to go!

## LICENSE
<a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-nd/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-nd/4.0/">Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License</a>.

## Dependencies:
- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)


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

## Credits
RowDog created the original script this is based on, and his work is foundational for this. Wouldn't have been possible without his original version https://forum.cfx.re/t/release-weazel-news-camera-and-mic-updated/116118

	
[Support - Discord](https://discord.gg/mFnNTV2Zce)
