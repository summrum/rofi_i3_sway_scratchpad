# rofi_i3_sway_scratchpad
A Rofi scratchpad mode for i3 and sway that shows all scratchpad windows. Allows selecting any or all windows to focus, along with closing any or all windows.
![example of scratchpad mode](https://github.com/summrum/rofi_i3_sway_scratchpad/blob/main/rofi_scratchpad_example.png?raw=true)
## Requirements:
**POSIX shell**  
**Rofi** window switcher/application launcher/dmenu replacement  
**jq** command-line JSON processor  
## Usage:
Ensure script is executable, then use one of the following options to add to your Rofi modi:  

**Option 1:** Launch Rofi with a script mode set using the syntax ```"{name}:{executable}"```  
```
rofi -show scratchpad -modi "scratchpad:/path/to/script/rofi_i3_sway_scratchpad.sh"
```
**Option 2:** Add custom mode to Rofi ```config.rasi``` file  
```
configuration {
	modi: "scratchpad:/path/to/script/rofi_i3_sway_scratchpad.sh";
}
```
Other modi can be added as usual seprarated by commas; the mode also doesn't have to be called "scratchpad", any name or glyph can be used.  

The scratchpad mode should then be available when launching Rofi, offering a list of scratchpad windows along with ```[ALL WINDOWS]``` if there are 2 or more scratchpad windows. Selecting any option will focus the selected window, or bring all scratchpad windows to the current workspace if ```[ALL WINDOWS]``` is selected. Using a key combination other than "select-entry" will close the selected window (e.g. pressing Shift+Delete if using default keyboard configuration will close the highlighted window - ```[ALL WINDOWS]``` will close all scratchpad windows).
