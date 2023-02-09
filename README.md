# CarbonUI
This is the official repository for the CarbonUI library.

# Preview
![Preview](https://github.com/WoffleTbh/CarbonUI/blob/main/githubAssets/preview1.png?raw=true)  
(The preview above uses the tokyonight theme, which is a darker version of the default theme)
# Usage
To import CarbonUI, you can use the code below:
```lua
getgenv().user = "WoffleTbh"
getgenv().repo = "CarbonUI"
local carbon = loadstring(game:HttpGet("https://raw.githubusercontent.com/" ..getgenv().user.. "/" ..getgenv().repo.. "/main/carbonui.lua"))()
```
To load themes, you can import carbon like so:
```lua
getgenv().user = "WoffleTbh"
getgenv().repo = "CarbonUI"
getgenv().theme = "tokyonight-storm" -- Default theme
local carbon = loadstring(game:HttpGet("https://raw.githubusercontent.com/" ..getgenv().user.. "/" ..getgenv().repo.. "/main/carbonui.lua"))()
```
More theme docs are in the `themes` folder.
### Examples
Code used in preview:
```lua
local window = carbon.new(640, 480, "CarbonUI Preview")
function createTestCategory(tab)
    local category = carbon.addCategory(tab, "Category")
    carbon.addButton(category, "Button", function()end)
    carbon.addInput(category, "Input", function()end)
    carbon.addDropdown(category, "Dropdown", {"foo", "bar", "baz"}, "none", function()end)
    carbon.addLabel(category, "Label")
    carbon.addSlider(category, "Slider", 0, 100, 50, 1, function()end)
    carbon.addToggle(category, "Toggle", function()end)
    carbon.addKeybind(category, "Keybind", false, function()end)
    carbon.addRGBColorPicker(category, "Color Picker", function()end)
end

local tab = carbon.addTab(window, "Tab")
createTestCategory(tab)
local tab = carbon.addTab(window, "Tab2")
createTestCategory(tab)
createTestCategory(tab)
createTestCategory(tab)
createTestCategory(tab)
createTestCategory(tab)
createTestCategory(tab)
```
