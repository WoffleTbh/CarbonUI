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
getgenv().token = nil -- When the repo is private and you have a token, you can still use carbon. Leave as nil otherwise
local carbon = loadstring(game:HttpGet("https://raw.githubusercontent.com/" ..getgenv().user.. "/" ..getgenv().repo.. "/main/carbonui.lua" .. (getgenv().token and ("?token=" .. getgenv().token) or "")))()
```
To load themes, you can import carbon like so:
```lua
getgenv().user = "WoffleTbh"
getgenv().repo = "CarbonUI"
getgenv().theme = "tokyonight-storm" -- Default theme
getgenv().token = nil
local carbon = loadstring(game:HttpGet("https://raw.githubusercontent.com/" ..getgenv().user.. "/" ..getgenv().repo.. "/main/carbonui.lua" .. (getgenv().token and ("?token=" .. getgenv().token) or "")))()
```
More theme docs are in the `themes` folder.
### Examples
Code used in preview:
```lua
local window = carbon.new(640, 480, "CarbonUI Preview")
function createTestCategory(tab)
    local category = carbon.addCategory(tab, "Category")
    local a = carbon.addButton(category, "Button", function()end)
    local b = carbon.addInput(category, "Input", function()end)
    local c = carbon.addDropdown(category, "Dropdown", {"foo", "bar", "baz"}, "none", function()end)
    local d = carbon.addLabel(category, "Label")
    local e = carbon.addSlider(category, "Slider", 0, 100, 50, 1, function()end)
    local f = carbon.addToggle(category, "Toggle", function()end)
    local g = carbon.addKeybind(category, "Keybind", false, "A", function()end)
    local h = carbon.addRGBColorPicker(category, "Color Picker", function()end)
    local widgetsEnabled = true
    carbon.addToggle(category, "Disable Widgets", function(s)
        widgetsEnabled = not s
    end)
    carbon.util.condition(a, function()return widgetsEnabled end)
    carbon.util.condition(b, function()return widgetsEnabled end)
    carbon.util.condition(c, function()return widgetsEnabled end)
    carbon.util.condition(d, function()return widgetsEnabled end)
    carbon.util.condition(e, function()return widgetsEnabled end)
    carbon.util.condition(f, function()return widgetsEnabled end)
    carbon.util.condition(g, function()return widgetsEnabled end)
    carbon.util.condition(h, function()return widgetsEnabled end)
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
