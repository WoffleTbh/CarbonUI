# CarbonUI
This is the official repository for the CarbonUI library.

# Preview
![Preview](https://github.com/WoffleTbh/CarbonUI/blob/main/githubAssets/preview1.png?raw=true)
# Usage
To import CarbonUI, you can use the code below:
```lua
local carbon = loadstring(game:HttpGet("https://raw.githubusercontent.com/WoffleTbh/CarbonUI/main/carbonui.lua"))()
```
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
    carbon.addKeybind(category, "Keybind", function()end)
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
