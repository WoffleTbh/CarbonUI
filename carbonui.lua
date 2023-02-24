--[[
    Carbon UI library
    by woffle#0001
]]--

local getgenv = getgenv or function() return _G end -- idk I guess some shitty exploits might not support getgenv

-- SETTINGS

local settings_autoFormatTabs = getgenv()["autoFormatTabs"] or true

local settings_user = getgenv()["user"] or "WoffleTbh"
local settings_repo = getgenv()["repo"] or "CarbonUI"
local settings_theme = getgenv()["theme"] or "tokyonight-storm"
local settings_token = getgenv()["token"]

-----------

local root = Instance.new("ScreenGui")
root.Name = "Carbon"
root.ZIndexBehavior = 1
local userInputService = game:GetService("UserInputService")

local plr = game.Players.LocalPlayer
local mouse = plr:GetMouse()

local loadedTheme

local function loadTheme(theme) loadedTheme = loadstring(game:HttpGet("https://raw.githubusercontent.com/" .. settings_user .. "/" .. settings_repo .. "/main/themes/" .. theme ..".lua" .. (settings_token and ("?token=" .. settings_token) or "")))() end
local function loadThemeFromFile(fileName) loadedTheme = loadstring(readfile(fileName))() end

loadTheme(settings_theme)

local util = {
    create = function(obj, properties)
        local o = Instance.new(obj)
        for i,v in pairs(properties) do
            if i == "Parent" then continue end
            o[i] = v
        end
        if properties["Parent"] then
            o.Parent = (type(properties["Parent"]) == "table" and properties["Parent"][1]) or properties["Parent"]
        end
        if properties["BorderSizePixel"] then return o end -- Prevent fancy stuff from happening on explicitly no-border stuff
        if o:IsA("GuiObject") then
            o.BorderSizePixel = 0
        end
        if o:IsA("GuiObject") and o.Parent and (o.Parent.Name == "inner" or o.Parent.Name == "main" or o.Parent.Name == "RGBSelection" or o.Parent.Name == "CarbonInfo" or o.Parent.Name == "Notif") then
            o.BorderSizePixel = loadedTheme["robloxBorder"]["window"]["size"]
            o.BorderColor3 = loadedTheme["robloxBorder"]["window"]["color"]
        end
        if o:IsA("GuiObject") and o.Parent and o.Parent.Parent and (o.Parent.Parent.Name == "category" or o.Parent.Name == "Tab" or o.Parent.Name == "selection") then
            o.BorderSizePixel = loadedTheme["widget"]["border"]["size"]
            o.BorderColor3 = loadedTheme["widget"]["border"]["color"]
            o.BorderMode = loadedTheme["widget"]["border"]["type"] == "inner" and Enum.BorderMode.Inset or Enum.BorderMode.Outline
        end
        if o:IsA("GuiObject") and o.Parent and o.Parent.Parent and o.Parent.Parent.Parent and o.Parent.Parent.Parent.Name == "category" and loadedTheme["widget"]["border"]["useBorderOnExtras"] then
            o.BorderSizePixel = loadedTheme["widget"]["border"]["size"]
            o.BorderColor3 = loadedTheme["widget"]["border"]["color"]
            o.BorderMode = loadedTheme["widget"]["border"]["type"] == "inner" and Enum.BorderMode.Inset or Enum.BorderMode.Outline
        end
        return o
    end,

    roundify = function(f, r)
        local uiCorner = Instance.new("UICorner", f)
        uiCorner.CornerRadius = UDim.new(0, r)
    end,

    makeDraggable = function(w)
        local dragging = false
        local offsetX, offsetY = 0, 0

        mouse.Button1Down:Connect(function()
            offsetX, offsetY = mouse.X - w.AbsolutePosition.X, mouse.Y - w.AbsolutePosition.Y
            dragging = not (offsetX < 0 or offsetY < 0 or offsetX > w.AbsoluteSize.X or offsetY > w.AbsoluteSize.Y)
            for _,ow in pairs(root:GetChildren()) do
                if ow == w or w.Parent == ow then continue end
                local _offsetX, _offsetY = mouse.X - ow.AbsolutePosition.X, mouse.Y - ow.AbsolutePosition.Y
                if not (_offsetX < 0 or _offsetY < 0 or _offsetX > ow.AbsoluteSize.X or _offsetY > ow.AbsoluteSize.Y) then
                    dragging = false
                end
            end
        end)
        mouse.Button1Up:Connect(function()
            dragging = false
        end)

        task.spawn(function()
            while true do
                if dragging then
                    if w.Parent and w.Parent.Name == "Shadow" then
                        w.Parent.Position = UDim2.new(0, mouse.X - offsetX, 0, mouse.Y - offsetY)
                    else
                        w.Position = UDim2.new(0, mouse.X - offsetX, 0, mouse.Y - offsetY)
                    end
                end
                task.wait()
            end
        end)
    end,

    getPos = function(category)
        category = category[1]
        local pos = 0
        for _, el in pairs(category:GetChildren()) do
            if el:IsA("UIPadding") then continue end
            pos += (el.Size.Y.Offset + loadedTheme["category"]["widgetSpacing"]) * el.Size.X.Scale
        end
        return pos
    end,

    isCategory = function(category)
        category = category[1]
        return category.Parent.Name == "category"
    end,

    isWindow = function(win)
        return type(win) == "table" and #win == 3 and win[1].Name == "Carbon" and win[2].Name == "Tabs" and win[3].Name == "Content"
    end,

    depend = function(bool, error)
        if not bool then
            warn(error)
            return false
        end
        return true
    end,

    checkTypes = function(values, types)
        for i,v in pairs(values) do
            if type(v) ~= types[i] then return false end
        end
        return true
    end,

    formatTab = function(tab)
        if tab.Name ~= "Tab" then
            warn("Can't format a non-tab")
            return
        end
        local categories = {}
        for _,category in pairs(tab:GetChildren()) do
            if category.Name == "category" then
                table.insert(categories, category)
            end
        end
        local function getTotalSize(r, e)
            local s = 0
            for _,v in pairs(r) do
                s += v.Size.Y.Offset
            end
            return s + e.Size.Y.Offset
        end
        local row1 = {}
        local row2 = {}
        local fw = {}
        while #categories > 0 do
            if categories[1].Size.X.Scale == 1 then
                table.insert(fw, categories[1])
            elseif getTotalSize(row1, categories[1]) > getTotalSize(row2, categories[1]) then
                table.insert(row2, categories[1])
            else
                table.insert(row1, categories[1])
            end
            table.remove(categories, 1)
        end
        local offY = loadedTheme["tab"]["categorySpacing"]
        for i,category in pairs(fw) do
            offY += fw[i].Position.Y.Offset + fw[i].Size.Y.Offset + loadedTheme["tab"]["categorySpacing"]
            if i == 1 then continue end
            category.Position = UDim2.new(0, 0, 0, fw[i-1].Position.Y.Offset + fw[i-1].Size.Y.Offset + 5)
        end
        for i,category in pairs(row1) do
            if i == 1 then
                category.Position = UDim2.new(0, 0, 0, offY)
                continue
            end
            category.Position = UDim2.new(0, 0, 0, row1[i-1].Position.Y.Offset + row1[i-1].Size.Y.Offset + loadedTheme["tab"]["categorySpacing"] + offY)
        end
        for i,category in pairs(row2) do
            if i == 1 then
                category.Position = UDim2.new(0.5, loadedTheme["tab"]["categorySpacing"], 0, offY)
                continue
            end
            category.Position = UDim2.new(0.5, loadedTheme["tab"]["categorySpacing"], 0, row2[i-1].Position.Y.Offset + row2[i-1].Size.Y.Offset + loadedTheme["tab"]["categorySpacing"] + offY)
        end
    end
}

local lang = {
    lua = {
        keywords = {"continue", "and", "break", "do", "else", "elseif", "end", "for", "function", "goto", "if", "in", "local", "not", "or", "repeat", "return", "then", "until", "while"},
        globals = {"game", "workspace", "script", "math", "string", "table", "print", "wait", "BrickColor", "Color3", "next", "pairs", "ipairs", "select", "unpack", "Instance", "Vector2", "Vector3", "CFrame", "Ray", "UDim2", "Enum", "assert", "error", "warn", "tick", "loadstring", "_G", "shared", "getfenv", "setfenv", "newproxy", "pcall", "ypcall", "xpcall", "rawequal", "rawset", "rawget", "tonumber", "tostring", "type", "typeof", "_VERSION", "coroutine", "delay", "require", "spawn", "LoadLibrary", "settings", "stats", "time", "UserSettings", "version", "Axes", "ColorSequence", "Faces", "ColorSequenceKeypoint", "NumberRange", "NumberSequence", "NumberSequenceKeypoint", "elapsedTime", "PhysicalProperties", "Rect", "Region3", "Region3int16", "UDim", "Vector2int16", "Vector3int16"},
        special = {"getrawmetatable", "setreadonly", "setmetatable", "getmetatable", "hookfunction", "hookmetamethod", "decompile", "getscriptbytecode", "Drawing", "getgenv", "getgc", "getrenv", "getsenv"},
        operators = "()[]{}#,.-+*/=<>~^"
    }
}

local icon = {
    copy      = "rbxassetid://12497486125",
    cursor    = "rbxassetid://12497489274",
    cut       = "rbxassetid://12497490584",
    checkmark = "rbxassetid://12497491532",
    delete    = "rbxassetid://12497492832",
    edit      = "rbxassetid://12497493748",
    redo      = "rbxassetid://12497494530",
    run       = "rbxassetid://12497561744",
    stop      = "rbxassetid://12497562859",
    pause     = "rbxassetid://12497563941"
}

util.disable = function(widget)
    widget = widget[1]
    if widget:FindFirstChild("disabled") then return end
    local overlay = util.create("Frame", {
        Parent = widget,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BorderSizePixel = 0,
        BackgroundTransparency = 1,
        Name = "disabled"
    })
    util.roundify(overlay, loadedTheme.widgetCornerRadius)
    for i = 20,10,-1 do
        overlay.BackgroundTransparency = i / 20
        task.wait()
    end
end
util.enable = function(widget)
    widget = widget[1]
    if not widget:FindFirstChild("disabled") then return end
    for i = 10,20 do
        widget:FindFirstChild("disabled").BackgroundTransparency = i / 20
        task.wait()
    end
    widget:FindFirstChild("disabled"):Destroy()
end
util.condition = function(w, check)
    task.spawn(function()
        while task.wait() do
            if not check() then
                util.disable(w)
            else
                util.enable(w)
            end
        end
    end)
end
util.addShadow = function(window, size)
    size = size / 10
    local shadow = util.create("Frame", {
        BackgroundTransparency = 1,
        Size = window.Size,
        Position = window.Position,
        Parent = root,
        Name = "Shadow"
    })
    window.Parent = shadow
    window.Position = UDim2.new(0, 0, 0, 0)
    window.Size = UDim2.new(1, 0, 1, 0)
    window.ZIndex += 1
    for i = 0, 9 do
        util.roundify(util.create("Frame", {
            Parent = shadow,
            Size = UDim2.new(1, size * (i+1)*2, 1, size * (i+1)*2),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 0.9 + i/100,
            ZIndex = window.ZIndex - 1,
            AnchorPoint = Vector2.new(0.5, 0.5)
        }), 24)
    end
    return shadow
end

local bindingFunc = function(k) end
local handlers = {}
local settingKeybind = false
local keysPressed = {}

userInputService.InputBegan:Connect(function(key, gameProcessed)
    if gameProcessed then return end
    if key.UserInputType == Enum.UserInputType.Keyboard then
        if settingKeybind then
            bindingFunc(key.KeyCode)
        else
            keysPressed[key.KeyCode] = true
            if handlers[key.KeyCode] then
                handlers[key.KeyCode][1]()
            end
        end
    end
end)
userInputService.InputEnded:Connect(function(key, gameProcessed)
    if gameProcessed then return end
    if key.UserInputType == Enum.UserInputType.Keyboard then
        keysPressed[key.KeyCode] = false
    end
end)

task.spawn(function()
    while true do
        for _,k in pairs(keysPressed) do
            if handlers[k] and handlers[k][2] then
                handlers[k][1]()
            end
        end
        task.wait()
    end
end)

carbon = {
    new = function(width, height, title, icon, btnOrder, btnPos)
        if not util.depend(util.checkTypes({width, height, title}, {"number", "number", "string"}), "Invalid types passed to carbon.new") then return end
        if not btnOrder then btnOrder = "CM" end
        if not btnPos then btnPos = "right" end
        local border = util.create("Frame", {
            Size = UDim2.new(0, width + 4, 0, height + 4),
            Position = UDim2.new(0,10,0,10),
            Parent = root,
            Name = "Carbon",
            ZIndex = 1,
            BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1
        })
        util.roundify(border, loadedTheme.cornerRadius)
        local shadow = util.addShadow(border, loadedTheme.shadowStrength)
        util.makeDraggable(border)
        local borderInner = util.create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = border,
            Name = "inner"
        })
        local maximizer = util.create("TextButton", {
            Parent = borderInner,
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Text = "",
            AutoButtonColor = false,
            Visible = false
        })

        local gradient = util.create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, loadedTheme.accent),
                ColorSequenceKeypoint.new(1, loadedTheme.secondaryAccent)
            }),
            Parent = border,
            Rotation = 45
        })
        task.spawn(function()
            while true do
                gradient.Rotation += 1
                task.wait()
            end
        end)

        local main = util.create("Frame", {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = loadedTheme.background,
            Parent = borderInner,
            Name = "main"
        })
        util.roundify(main, loadedTheme.cornerRadius)

        local content = util.create("ScrollingFrame", {
            Size = UDim2.new(1,-120,1,-30),
            Position = UDim2.new(0,120,0,30),
            BackgroundTransparency = 1,
            Parent = main,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0,0,0,0),
            Name = "Content"
        })
        local sidebar = util.create("Frame", {
            Size = UDim2.new(0, 120, 0, height),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = main
        })

        local topbar = util.create("Frame", {
            Size = UDim2.new(0, width, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = main
        })
        util.roundify(topbar, loadedTheme.cornerRadius)
        util.create("Frame", {
            Size = UDim2.new(0, width, 0, 15),
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = topbar,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        util.roundify(sidebar, loadedTheme.cornerRadius)
        util.create("Frame", {
            Size = UDim2.new(0.5, 0, 0, height),
            Position = UDim2.new(0.5, 0, 0),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = sidebar,
            BorderSizePixel = 0
        })
        local tabs = util.create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,-30),
            Position = UDim2.new(0,0,0,30),
            BackgroundTransparency = 1,
            Parent = sidebar,
            BorderSizePixel = 0,
            AutomaticCanvasSize = 2,
            CanvasSize = UDim2.new(1,0,0,0),
            Name = "Tabs"
        })
        util.create("UIListLayout", {
            Parent = tabs
        })

        local _title = util.create("TextLabel", {
            Size = UDim2.new(0, width-(icon and 30 or 0), 0, 30),
            Position = UDim2.new(0, icon and 30 or 0, 0, 0),
            BackgroundTransparency = 1,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  " .. title,
            Parent = topbar,
            ZIndex = 100
        })

        -- control buttons

        local closePos = 0
        local minPos = 0
        local off = 15
        for i = 1, string.len(btnOrder) do
            if string.sub(btnOrder, i, i) == "M" then
                minPos = off
            elseif string.sub(btnOrder, i, i) == "C" then
                closePos = off
            end
            off += 20
        end
        local i = 0
        local j = 1
        if btnPos == "right" then
            i = 1
            j = -1
        else
            _title.Position += UDim2.new(0, off - 10, 0, 0)
        end
        local close = util.create("TextButton", {
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(i, closePos * j, 0.5, 0),
            BackgroundColor3 = loadedTheme.closeBtnColor,
            Parent = topbar,
            ZIndex = 4,
            Text = loadedTheme.closeBtnText,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            AnchorPoint = Vector2.new(0.5, 0.5)
        })
        util.roundify(close, 15)
        close.MouseButton1Down:Connect(function()
            root:Destroy()
        end)

        local minimize = util.create("TextButton", {
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(i, minPos * j, 0.5, 0),
            BackgroundColor3 = loadedTheme.minimizeBtnColor,
            Parent = topbar,
            ZIndex = 4,
            Text =  loadedTheme.minimizeBtnText,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            AnchorPoint = Vector2.new(0.5, 0.5)
        })
        util.roundify(minimize, 15)
        local minimized = false

        local function toggleMinimize()
            if not minimized then
                minimized = true
                maximizer.Visible = true
                shadow:TweenSize(UDim2.new(0, 30, 0, 30), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.25, true)
                task.delay(0.25, function()
                    main.Visible = false
                end)
            else
                minimized = false
                maximizer.Visible = false
                shadow:TweenSize(UDim2.new(0, width + 4, 0, height + 4), Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, 0.25, true)
                main.Visible = true
            end
        end

        minimize.MouseButton1Down:Connect(toggleMinimize)
        maximizer.MouseButton1Down:Connect(toggleMinimize)
        return {border, tabs, content}
    end,
    addTab = function(win, title)
        if not
            util.depend(util.isWindow(win), "Can't add a Tab to a non-window.") or not
            util.depend(util.checkTypes({title}, {"string"}), "Tab title must be a string!")
        then return end
        local tab = util.create("ScrollingFrame", {
            Size = UDim2.new(1,0,1,0),
            BackgroundTransparency = 1,
            Parent = win[3],
            Position = #win[2]:GetChildren() < 2 and UDim2.new(0,0,0,0) or UDim2.new(0,0,-1,0),
            Name = "Tab",
            ScrollBarThickness = 0,
            BorderSizePixel = 0
        })
        util.roundify(tab, loadedTheme.cornerRadius)
        util.create("UIPadding", {
            Parent = tab,
            PaddingLeft = loadedTheme.tab.padding.left,
            PaddingTop = loadedTheme.tab.padding.top,
            PaddingBottom = loadedTheme.tab.padding.bottom,
            PaddingRight = loadedTheme.tab.padding.right,
        })
        task.spawn(function()
            while true do
                local lowest = 0
                for _, category in pairs(tab:GetChildren()) do
                    if not category:IsA("GuiObject") then continue end
                    if category.Position.Y.Offset + category.Size.Y.Offset > lowest then lowest = category.Position.Y.Offset + category.Size.Y.Offset end
                end
                tab.CanvasSize = UDim2.new(0,0,0,lowest + 10)
                task.wait()
            end
        end)

        local tabBtn = util.create("TextButton", {
            Size = UDim2.new(1,0,0,25),
            BackgroundColor3 = #win[2]:GetChildren() < 2 and loadedTheme.background or loadedTheme.topbar,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = title,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = win[2],
            BorderSizePixel = 0,
        })

        local function _select()
            if tabBtn.BackgroundColor3 == loadedTheme.background then return end
            for _,v in pairs(win[3]:GetChildren()) do
                if v == tab then continue end
                v:TweenPosition(UDim2.new(0, 0, -1, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
            end
            tab.Position = UDim2.new(0,0,1,0)
            tab:TweenPosition(UDim2.new(0, 0, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
            for _,v in pairs(win[2]:GetChildren()) do
                if not v:IsA("TextButton") then continue end
                v.BackgroundColor3 = loadedTheme.topbar
            end
            tabBtn.BackgroundColor3 = loadedTheme.background
        end

        tabBtn.MouseButton1Down:Connect(_select)
        return {
            tab,
            select = _select
        }
    end,
    addCategory = function(tab, title, fullWidth)
        tab = tab[1]
        if not
            util.depend(tab.Name == "Tab", "Can't add a category to a non-tab.") or not
            util.depend(util.checkTypes({title}, {"string"}), "Category title must be a string!")
        then return end
        local category = util.create("Frame", {
            BackgroundColor3 = loadedTheme["category"]["useCustomColors"] and loadedTheme["category"]["bgColor"] or loadedTheme.topbar,
            Parent = tab,
            Name = "category",
            Size = UDim2.new(0.5 + (fullWidth and 0.5 or 0), -5 + (fullWidth and 5 or 0), 0, (loadedTheme.category.titleVisible and 20 or 0) + (loadedTheme.category.separatorVisible and 1 or 0) + loadedTheme.category.padding.top.Offset)
        })

        util.roundify(category, loadedTheme.cornerRadius)

        local _title
        if loadedTheme.category.titleVisible then
            _title = util.create("TextLabel", {
                Parent = category,
                Size = UDim2.new(1,0,0,20),
                BackgroundTransparency = 1,
                Font = loadedTheme["font"],
                FontSize = loadedTheme["fontSize"],
                Text = title,
                TextColor3 = loadedTheme.secondaryForeground,
            })
        end
        if loadedTheme.category.separatorVisible then
            util.create("Frame", {
                Parent = category,
                Size = UDim2.new(1,0,0,1),
                BorderSizePixel = 0,
                BackgroundColor3 = loadedTheme.secondaryForeground,
                Position = UDim2.new(0,0,0,20)
            })
        end
        local categoryContent = util.create("Frame", {
            Parent = category,
            Size = UDim2.new(1,0,1,(loadedTheme.category.titleVisible and -20 or 0) - (loadedTheme.category.separatorVisible and 1 or 0)),
            Position = UDim2.new(0,0,0,(loadedTheme.category.titleVisible and 20 or 0) + (loadedTheme.category.separatorVisible and 1 or 0)),
            BackgroundTransparency = 1,
        })
        categoryContent.ChildAdded:Connect(function(child)
            if not child:IsA("GuiObject") then return end
            category.Size += UDim2.new(0, 0, 0, child.AbsoluteSize.Y + loadedTheme["category"]["widgetSpacing"])
            if settings_autoFormatTabs then
                util.formatTab(tab)
            end
        end)
        util.create("UIPadding", {
            Parent = categoryContent,
            PaddingLeft = loadedTheme.category.padding.left,
            PaddingTop = loadedTheme.category.padding.top,
            PaddingBottom = loadedTheme.category.padding.bottom,
            PaddingRight = loadedTheme.category.padding.right,
        })
        if settings_autoFormatTabs then
            util.formatTab(tab) -- empty categories would fuck up fomatting
        end
        return {
            categoryContent,
            changeTitle = function(new)
                if _title then
                    _title.Text = new
                end
            end
        }
    end,
    addButton = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a button to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addButton")
        then return end
        local btn = util.create("TextButton", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = text,
            TextColor3 = loadedTheme.secondaryForeground,
            Size = UDim2.new(1, 0, 0, 25),
            AutoButtonColor = false,
            ClipsDescendants = true,
            Position = UDim2.new(0,0,0,util.getPos(category))
        })
        util.roundify(btn, loadedTheme.widgetCornerRadius)
        local function click(x,y)
            if btn:FindFirstChild("disabled") then return end
            callback()
            local circleEffect = util.create("Frame", {
                Parent = btn,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0,1,0,1),
                Position = UDim2.new(0, x, 0, y),
                AnchorPoint = Vector2.new(0.5,0.5)
            })
            util.create("UICorner", {
                Parent = circleEffect,
                CornerRadius = UDim.new(1,0)
            })
            task.spawn(function()
                for i = 0,40 do
                    circleEffect.Size += UDim2.new(0,25,0,25)
                    circleEffect.BackgroundTransparency = i / 40
                    task.wait()
                end
                circleEffect:Destroy()
            end)
        end
        btn.MouseButton1Down:Connect(function()
            click(mouse.X - btn.AbsolutePosition.X, mouse.Y - btn.AbsolutePosition.Y)
        end)
        return {
            btn,
            click = function()
                click(btn.AbsolutePosition.X + btn.AbsoluteSize.X / 2 - btn.AbsolutePosition.X, btn.AbsolutePosition.Y + btn.AbsoluteSize.Y / 2 - btn.AbsolutePosition.Y)
            end,
            setText = function(txt)
                btn.Text = txt
            end,
            disable = function()
                util.disable(btn)
            end,
            enable = function()
                util.enable(btn)
            end
        }
    end,
    addToggle = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a toggle to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addToggle")
        then return end
        local toggleBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(toggleBg, loadedTheme.widgetCornerRadius)
        local toggle = util.create("TextButton", {
            Text = "",
            Parent = toggleBg,
            Size = UDim2.new(0,21,0,21),
            Position = UDim2.new(0,2,0,2),
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
            AutoButtonColor = false
        })
        local toggleDisplay = toggle:Clone()
        toggleDisplay.BackgroundColor3 = loadedTheme.secondaryAccent
        toggleDisplay.Size = UDim2.new(0,0,0,0)
        toggleDisplay.AnchorPoint = Vector2.new(0.5,0.5)
        toggleDisplay.Position = UDim2.new(0.5,0,0.5,0)
        toggleDisplay.Parent = toggle
        toggleDisplay.Visible = false
        util.roundify(toggle, loadedTheme.widgetCornerRadius)
        util.roundify(toggleDisplay, loadedTheme.widgetCornerRadius)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = toggleBg,
            Position = UDim2.new(0,23,0,0),
            Size = UDim2.new(1,-23,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local toggeled = false
        local function _toggle()
            if toggleBg:FindFirstChild("disabled") then return end
            if not toggeled then
                toggleDisplay.Visible = true
                toggleDisplay:TweenSize(UDim2.new(1,0,1,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
            else
                toggleDisplay:TweenSize(UDim2.new(0,0,0,0), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.2, true)
                task.delay(0.2, function()
                    toggleDisplay.Visible = false
                end)
            end
            toggeled = not toggeled
            callback(toggeled)
        end
        toggle.MouseButton1Down:Connect(_toggle)
        toggleDisplay.MouseButton1Down:Connect(_toggle)
        return {
            toggleBg,
            toggle = _toggle,
            setLabeltext = function(_txt)
                txt.Text = _txt
            end,
            disable = function()
                util.disable(toggleBg)
            end,
            enable = function()
                util.enable(toggleBg)
            end
        }
    end,
    addSlider = function(category, text, min, max, default, decimalPercision, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a slider to non-category") or not
            util.depend(util.checkTypes({text, min, max, default, decimalPercision, callback}, {"string", "number", "number", "number", "number", "function"}), "Invalid types passed to carbon.addSlider")
        then return end
        local decimalPercision = math.clamp(decimalPercision, 0, math.huge)
        local sliderBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(sliderBg, loadedTheme.widgetCornerRadius)
        local barBg = util.create("TextButton", {
            Text = "",
            Parent = sliderBg,
            Size = UDim2.new(1,-20,0,7),
            Position = UDim2.new(0,10, 1,-19),
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
            AutoButtonColor = false
        })
        local bar = barBg:Clone()
        bar.BackgroundColor3 = loadedTheme.secondaryAccent
        bar.Position = UDim2.new(0,0,0,0)
        bar.Parent = barBg
        bar.Size = UDim2.new((math.clamp(default, min, max) - min) / (max-min), 0, 1, 0)
        util.roundify(barBg, loadedTheme["widget"]["isSliderRound"] and 12 or 0)
        util.roundify(bar, loadedTheme["widget"]["isSliderRound"] and 12 or 0)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = sliderBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(1,0,0.5,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local display = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = tostring(math.clamp(default, min, max)) .. "  ",
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = sliderBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(1,0,0.5,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Right
        })
        local dragging = false
        local function beginDrag()
            dragging = true
        end
        local function endDrag()
            dragging = false
        end
        bar.MouseButton1Down:Connect(beginDrag)
        barBg.MouseButton1Down:Connect(beginDrag)
        bar.MouseButton1Up:Connect(endDrag)
        barBg.MouseButton1Up:Connect(endDrag)
        mouse.Button1Up:Connect(endDrag)
        task.spawn(function()
            while true do
                if dragging and not sliderBg:FindFirstChild("disabled") then
                    local percent = math.clamp((mouse.X - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
                    local value = math.round((percent * (max-min) + min)*(10^decimalPercision))/(10^decimalPercision)
                    display.Text = tostring(value) .. "  "
                    bar.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
                    callback(value)
                end
                task.wait()
            end
        end)
        return {
            sliderBg,
            setMin = function(newMin)
                min = newMin
            end,
            setMax = function(newMax)
                max = newMax
            end,
            setDefault = function(newDef)
                default = newDef
            end,
            setPercision = function(newPer)
                decimalPercision = newPer
            end,
            setPercent = function(v)
                local percent = v
                local value = math.round((percent * (max-min) + min)*(10^decimalPercision))/(10^decimalPercision)
                display.Text = tostring(value) .. "  "
                bar.Size = UDim2.new((math.clamp(value, min, max) - min) / (max-min), 0, 1, 0)
            end,
            setValue = function(v)
                local value = v*(10^decimalPercision)/(10^decimalPercision)
                display.Text = tostring(value) .. "  "
                bar.Size = UDim2.new((math.clamp(value, min, max) - min) / (max-min), 0, 1, 0)
            end,
            setLabelText = function(_txt)
                txt.text = _txt
            end,
            disable = function()
                util.disable(barBg)
            end,
            enable = function()
                util.enable(barBg)
            end
        }
    end,
    addInput = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add an input to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addInput")
        then return end
        local inputBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(inputBg, loadedTheme.widgetCornerRadius)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = inputBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local input = util.create("TextBox", {
            Text = "",
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            ClearTextOnFocus = false,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = inputBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(input, loadedTheme.widgetCornerRadius)
        input.FocusLost:Connect(function()
            callback(input.Text)
        end)
        task.spawn(function()
            while task.wait() do
                input.TextEditable = not inputBg:FindFirstChild("disabled")
            end
        end)
        return {
            inputBg,
            setLabelText = function(_txt)
                txt.Text = _txt
            end,
            setInputText = function(_txt)
                input.Text = _txt
            end,
            disable = function()
                util.disable(inputBg)
            end,
            enable = function()
                util.enable(inputBg)
            end
        }
    end,
    addRGBColorPicker = function(category, text, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a color picker to non-category") or not
            util.depend(util.checkTypes({text, callback}, {"string", "function"}), "Invalid types passed to carbon.addRGBColorPicker")
        then return end
        local bg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(bg, loadedTheme.widgetCornerRadius)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = bg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local colorBtn = util.create("TextButton", {
            Text = "",
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = bg,
            Position = UDim2.new(1,-23,0,2),
            Size = UDim2.new(0,21,0,21),
            BackgroundColor3 = Color3.fromRGB(255,0,0),
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(colorBtn, loadedTheme.widgetCornerRadius)
        colorBtn.MouseButton1Down:Connect(function()
            if bg:FindFirstChild("disabled") then return end
            if root:FindFirstChild("RGBSelection") then
                root.RGBSelection:Destroy()
            end
            local border = util.create("Frame", {
                Size = UDim2.new(0, 354, 0, 242),
                Position = UDim2.new(0,mouse.X,0,mouse.Y),
                Parent = root,
                Name = "RGBSelection",
                ZIndex = 2,
                BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1
            })
            util.roundify(border, loadedTheme.cornerRadius)
            local shadow = util.addShadow(border, loadedTheme.shadowStrength)
            shadow.Name = "RGBSelection"

            local gradient = util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 212)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 255))
                }),
                Parent = border,
                Rotation = 45
            })

            task.spawn(function()
                while true do
                    gradient.Rotation += 1
                    task.wait()
                end
            end)
            local selectionWindow = util.create("Frame", {
                Parent = border,
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                BackgroundColor3 = loadedTheme.topbar,
                ZIndex = 3,
                Name = "selection"
            })
            util.roundify(selectionWindow, loadedTheme.cornerRadius)
            local rgb = util.create("Frame", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 200, 0, 200),
                Position = UDim2.new(0, 10, 0, 10),
                BorderSizePixel = 0
            })
            local seq = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1/6, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(2/6, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(3/6, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(4/6, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(5/6, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            util.create("UIGradient", {
                Color = seq,
                Parent = rgb,
            })
            local saturation = util.create("Frame", {
                Parent = rgb,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BorderSizePixel = 0
            })
            util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                }),
                Parent = saturation,
                Rotation = -90,
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1)
                })
            })
            local rgbDetector = util.create("TextButton", {
                Parent = rgb,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ""
            })
            local value = util.create("Frame", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 21, 0, 200),
                Position = UDim2.new(0, 220, 0, 10),
                BorderSizePixel = 0
            })
            local valueDetector = util.create("TextButton", {
                Parent = value,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = ""
            })
            local valueGradient = util.create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                }),
                Parent = value,
                Rotation = 90
            })

            util.create("Frame", {
                Parent = selectionWindow,
                Position = UDim2.new(0, 250, 0, 15),
                Size = UDim2.new(0,90,0,50),
                BackgroundColor3 = colorBtn.BackgroundColor3,
                BorderSizePixel = 0
            })
            local preview = util.create("Frame", {
                Parent = selectionWindow,
                Position = UDim2.new(0, 250, 0, 65),
                Size = UDim2.new(0,90,0,55),
                BackgroundColor3 = Color3.fromRGB(255,0,0),
                BorderSizePixel = 0
            })

            local picker = util.create("Frame", {
                Parent = rgb,
                Size = UDim2.new(0, 4, 0, 4),
                AnchorPoint = Vector2.new(0.5, 0.5),
                BackgroundColor3 = Color3.new(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 0.3
            })

            local inputHex = util.create("TextBox", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 90, 0, 25),
                Position = UDim2.new(0, 250, 0, 125),
                BackgroundColor3 = loadedTheme.background,
                Text = "",
                Font = loadedTheme["font"],
                FontSize = loadedTheme["fontSize"],
                TextColor3 = loadedTheme.secondaryForeground,
                PlaceholderText = "#FFFFFF"
            })

            util.roundify(inputHex, loadedTheme.widgetCornerRadius)

            local r = util.create("TextBox", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 25, 0, 25),
                Position = UDim2.new(0, 250, 0, 155),
                BackgroundColor3 = loadedTheme.background,
                Text = "",
                Font = loadedTheme["font"],
                FontSize = Enum.FontSize.Size14,
                TextColor3 = loadedTheme.secondaryForeground,
                PlaceholderText = "r"
            })

            util.roundify(r, loadedTheme.widgetCornerRadius)

            local g = r:Clone()
            g.Parent = selectionWindow
            g.Position += UDim2.new(0, 30, 0, 0)
            g.Size += UDim2.new(0,5,0,0)
            g.PlaceholderText = "g"

            local b = g:Clone()
            b.Parent = selectionWindow
            b.Position += UDim2.new(0, 35, 0, 0)
            b.Size -= UDim2.new(0,5,0,0)
            b.PlaceholderText = "b"

            local h = r:Clone()
            h.Position += UDim2.new(0, 0, 0, 30)
            h.Parent = selectionWindow
            h.PlaceholderText = "h"
            local s = g:Clone()

            s.Position += UDim2.new(0, 0, 0, 30)
            s.Parent = selectionWindow
            s.PlaceholderText = "s"
            local v = b:Clone()

            v.Position += UDim2.new(0, 0, 0, 30)
            v.Parent = selectionWindow
            v.PlaceholderText = "v"

            inputHex.FocusLost:Connect(function()
                preview.BackgroundColor3 = Color3.fromHex(inputHex.Text)
            end)

            r.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text, g.Text or 0, b.Text or 0)end)
            end)

            g.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text or 0, g.Text, b.Text or 0)end)
            end)

            b.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromRGB(r.Text or 0, g.Text or 0, b.Text)end)
            end)

            h.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text, s.Text or 0, v.Text or 0)end)
            end)

            s.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text or 0, s.Text, v.Text or 0)end)
            end)

            v.FocusLost:Connect(function()
                pcall(function()preview.BackgroundColor3 = Color3.fromHSV(h.Text or 0, s.Text or 0, v.Text)end)
            end)

            local btnConfirm = util.create("TextButton", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 97, 0, 21),
                Position = UDim2.new(0, 10, 1, -24),
                Text = "Confirm",
                Font = loadedTheme["font"],
                FontSize = loadedTheme["fontSize"],
                TextColor3 = loadedTheme.secondaryForeground,
                BackgroundColor3 = loadedTheme.background
            })

            local btnCancel = util.create("TextButton", {
                Parent = selectionWindow,
                Size = UDim2.new(0, 97, 0, 21),
                Position = UDim2.new(0, 113, 1, -24),
                Text = "Cancel",
                Font = loadedTheme["font"],
                FontSize = loadedTheme["fontSize"],
                TextColor3 = loadedTheme.secondaryForeground,
                BackgroundColor3 = loadedTheme.background
            })

            util.roundify(btnConfirm, loadedTheme.widgetCornerRadius)
            util.roundify(btnCancel, loadedTheme.widgetCornerRadius)

            btnCancel.MouseButton1Down:Connect(function()
                shadow:Destroy()
            end)
            btnConfirm.MouseButton1Down:Connect(function()
                callback(preview.BackgroundColor3)
                colorBtn.BackgroundColor3 = preview.BackgroundColor3
                shadow:Destroy()
            end)

            local picking = false
            local pickingValue = false

            local function beginPicking()
                if mouse.X >= rgb.AbsolutePosition.X and mouse.Y >= rgb.AbsolutePosition.Y and mouse.X <= rgb.AbsolutePosition.X + rgb.AbsoluteSize.X and mouse.Y <= rgb.AbsolutePosition.Y + rgb.AbsoluteSize.Y then
                    picking = true
                elseif mouse.X >= value.AbsolutePosition.X and mouse.Y >= value.AbsolutePosition.Y and mouse.X <= value.AbsolutePosition.X + value.AbsoluteSize.X and mouse.Y <= value.AbsolutePosition.Y + value.AbsoluteSize.Y then
                    pickingValue = true
                end
            end
            local function endPicking()
                picking = false
                pickingValue = false
            end

            rgbDetector.MouseButton1Down:Connect(beginPicking)
            valueDetector.MouseButton1Down:Connect(beginPicking)
            mouse.Button1Down:Connect(beginPicking)
            mouse.Button1Up:Connect(endPicking)
            rgbDetector.MouseButton1Up:Connect(endPicking)
            valueDetector.MouseButton1Up:Connect(endPicking)
            local function getColorOnOffset(cs, time)
                if time == 0 then return cs.Keypoints[1].Value end
                if time == 1 then return cs.Keypoints[#cs.Keypoints].Value end
                for i = 1, #cs.Keypoints - 1 do
                    local this = cs.Keypoints[i]
                    local next = cs.Keypoints[i + 1]
                    if time >= this.Time and time < next.Time then
                        local alpha = (time - this.Time) / (next.Time - this.Time)
                        return Color3.new(
                            (next.Value.R - this.Value.R) * alpha + this.Value.R,
                            (next.Value.G - this.Value.G) * alpha + this.Value.G,
                            (next.Value.B - this.Value.B) * alpha + this.Value.B
                        )
                    end
                end
            end
            task.spawn(function()
                while true do
                    if picking then
                        picker.Position = UDim2.new(0, math.clamp(mouse.X - rgb.AbsolutePosition.X, 0, rgb.AbsoluteSize.X), 0, math.clamp(mouse.Y - rgb.AbsolutePosition.Y, 0, rgb.AbsoluteSize.Y))
                        local color = getColorOnOffset(seq, picker.Position.X.Offset / 200)
                        color = Color3.fromRGB(
                            math.clamp(color.R * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.G * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.B * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255)
                        )
                        valueGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, color),
                            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))
                        })
                        preview.BackgroundColor3 = color
                        r.Text = math.floor(color.R * 255)
                        g.Text = math.floor(color.G * 255)
                        b.Text = math.floor(color.B * 255)
                        local hv, sv, vv = color:ToHSV()
                        h.Text = math.floor(hv * 360)
                        s.Text = math.floor(sv * 100)
                        v.Text = math.floor(vv * 100)
                        inputHex.Text = "#" .. color:ToHex()
                    elseif pickingValue then
                        local color = getColorOnOffset(seq, picker.Position.X.Offset / 200)
                        color = Color3.fromRGB(
                            math.clamp(color.R * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.G * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255),
                            math.clamp(color.B * 255 + picker.Position.Y.Offset / 200 * 255, 0, 255)
                        )
                        local newColor = Color3.new(
                            color.R * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1)),
                            color.G * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1)),
                            color.B * (1 - math.clamp(math.clamp(mouse.Y - value.AbsolutePosition.Y, 0, 200) / 200, 0, 1))
                        )
                        preview.BackgroundColor3 = newColor
                        r.Text = math.floor(newColor.R * 255)
                        g.Text = math.floor(newColor.G * 255)
                        b.Text = math.floor(newColor.B * 255)
                        local hv, sv, vv = newColor:ToHSV()
                        h.Text = math.floor(hv * 360)
                        s.Text = math.floor(sv * 100)
                        v.Text = math.floor(vv * 100)
                        inputHex.Text = "#" .. newColor:ToHex()
                    end
                    task.wait()
                end
            end)
        end)
        return {
            bg,
            setLabelText = function(_txt)
                txt.text = _txt
            end,
            setValue = function(v)
                colorBtn.BackgroundColor3 = v
            end,
            disable = function()
                util.disable(bg)
            end,
            enable = function()
                util.enable(bg)
            end
        }
    end,
    addLabel = function(category, text)
        if not
            util.depend(util.isCategory(category), "Can't add a label to non-category") or not
            util.depend(util.checkTypes({text}, {"string"}), "Invalid types passed to carbon.addLabel")
        then return end
        local txt = util.create("TextLabel", {
            Parent = category,
            BackgroundTransparency = 1,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = text,
            TextColor3 = loadedTheme.secondaryForeground,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category))
        })
        return {
            txt,
            setText = function(_txt)
                txt.Text = _txt
            end,
            disable = function()
                util.disable(txt)
            end,
            enable = function()
                util.enable(txt)
            end
        }
    end,
    addDropdown = function(category, text, values, default, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a dropdown to non-category") or not
            util.depend(util.checkTypes({text, values, default, callback}, {"string", "table", "string", "function"}), "Invalid types passed to carbon.addDropdown")
        then return end
        local dropdownBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(dropdownBg, loadedTheme.widgetCornerRadius)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = dropdownBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local selectBtn = util.create("TextButton", {
            Text = default, -- Doesn't have to be in the list of values in case it's "none" or something
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = dropdownBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(selectBtn, loadedTheme.widgetCornerRadius)
        local indicator = util.create("TextLabel", {
            Text = "+",
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Size = UDim2.new(0, 21, 0, 21),
            Position = UDim2.new(1,-21,0,0),
            Parent = selectBtn,
            BackgroundTransparency = 1
        })
        selectBtn.MouseButton1Down:Connect(function()
            if dropdownBg:FindFirstChild("disabled") then return end
            if root:FindFirstChild(text .. "Sel") then
                root:FindFirstChild(text .. "Sel"):TweenSize(UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
                task.delay(0.2, function()root:FindFirstChild(text .. "Sel"):Destroy()end)
                indicator.Text = "+"
                return
            end
            indicator.Text = "-"
            local selection = util.create("Frame", {
                Parent = root,
                Size = UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0),
                Position = UDim2.new(0, selectBtn.AbsolutePosition.X, 0, selectBtn.AbsolutePosition.Y + selectBtn.AbsoluteSize.Y),
                BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
                Name = text .. "Sel",
                ClipsDescendants = true
            })
            util.create("UIListLayout", {
                Parent = selection
            })
            util.roundify(selection, loadedTheme.widgetCornerRadius)
            for i,v in pairs(values) do
                util.create("TextButton", {
                    Parent = selection,
                    Size = UDim2.new(1,0,0,20),
                    Text = tostring(v),
                    Font = loadedTheme["font"],
                    FontSize = loadedTheme["fontSize"],
                    TextColor3 = loadedTheme.secondaryForeground,
                    BackgroundTransparency = 1
                }).MouseButton1Down:Connect(function()
                    callback(v)
                    root:FindFirstChild(text .. "Sel"):TweenSize(UDim2.new(0, selectBtn.AbsoluteSize.X, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
                    task.delay(0.2, function()root:FindFirstChild(text .. "Sel"):Destroy()end)
                    indicator.Text = "+"
                    selectBtn.Text = tostring(v)
                end)
            end
            selection:TweenSize(UDim2.new(0, selectBtn.AbsoluteSize.X, 0, #values * 20), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.2, true)
        end)
        return {
            dropdownBg,
            setLabelText = function(_txt)
                txt.Text = _txt
            end,
            setValue = function(v)
                selectBtn.Text = v
            end,
            disable = function()
                util.disable(dropdownBg)
            end,
            enable = function()
                util.enable(dropdownBg)
            end
        }
    end,
    addKeybind = function(category, text, allowHold, default, callback)
        if not
            util.depend(util.isCategory(category), "Can't add a keybind to non-category") or not
            util.depend(util.checkTypes({text, allowHold, default, callback}, {"string", "boolean", "string", "function"}), "Invalid types passed to carbon.addKeybinds")
        then return end
        local kbBg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(kbBg, loadedTheme.widgetCornerRadius)
        local txt = util.create("TextLabel", {
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Text = "  " .. text,
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = kbBg,
            Position = UDim2.new(0,0,0,0),
            Size = UDim2.new(0.5,0,1,0),
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left
        })
        local key = util.create("TextButton", {
            Text = "[ " .. default .. " ]",
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Parent = kbBg,
            Position = UDim2.new(0.5,-2,0,2),
            Size = UDim2.new(0.5,0,1,-4),
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.secondaryBg or loadedTheme.topbar,
            TextXAlignment = Enum.TextXAlignment.Center
        })
        util.roundify(key, loadedTheme.widgetCornerRadius)
        handlers[Enum.KeyCode[default]] = {callback, allowHold}
        key.MouseButton1Down:Connect(function()
            if kbBg:FindFirstChild("disabled") then return end
            if settingKeybind then return end
            settingKeybind = true
            key.Text = "[ ... ]"
            bindingFunc = function(k)
                settingKeybind = false
                key.Text = "[ " .. tostring(k.Name) .. " ]"
                handlers[k] = {callback, allowHold}
                bindingFunc = function(k) end
            end
        end)
        return {
            kbBg,
            setLabelText = function(_txt)
                txt.Text = _txt
            end,
            setKey = function(k)
                handlers[Enum.KeyCode[default]] = {callback, allowHold}
                key.Text = "[ " .. k .. " ]"
            end,
            disable = function()
                util.disable(kbBg)
            end,
            enable = function()
                util.enable(kbBg)
            end
        }
    end,
    inline = function(oldWidget, newWidget)
        oldWidget = oldWidget[1]
        newWidget = newWidget[1]
        if oldWidget.Parent.Parent.Name ~= "category" then
            warn("Attempt to inline widget to nonwidget!")
            return
        end
        if oldWidget.Size.Y.Offset ~= newWidget.Size.Y.Offset then
            warn("Cannot inline widgets varying in height!")
            return
        end
        if oldWidget.Size.X.Scale ~= 1 then
            warn("Can only inline at most 2 widgets together!")
            return
        end
        oldWidget.Size = UDim2.new(0.5, -3, 0, oldWidget.Size.Y.Offset)
        newWidget.Size = UDim2.new(0.5, -3, 0, newWidget.Size.Y.Offset)
        newWidget.Position = oldWidget.Position + UDim2.new(0.5, 3, 0, 0)
    end,
    newInfo = function(title, text, buttons, width, height, callback)
        width = width or 300
        height = height or 300
        local border = util.create("Frame", {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0.5,-width/2,0.5,-height/2),
            Parent = root,
            Name = "CarbonInfo",
            ZIndex = 2,
            BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1
        })
        util.roundify(border, loadedTheme.cornerRadius)
        local shadow = util.addShadow(border, loadedTheme.shadowStrength)

        local gradient = util.create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, loadedTheme.accent),
                ColorSequenceKeypoint.new(1, loadedTheme.secondaryAccent)
            }),
            Parent = border,
            Rotation = 45
        })

        task.spawn(function()
            while true do
                gradient.Rotation += 1
                task.wait()
            end
        end)
        local main = util.create("Frame", {
            Parent = border,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = loadedTheme.background,
            ZIndex = 3
        })
        util.roundify(main, loadedTheme.cornerRadius)

        local topbar = util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = main
        })
        util.roundify(topbar, loadedTheme.cornerRadius)
        util.create("Frame", {
            Size = UDim2.new(1, 0, 0, 15),
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = topbar,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        util.create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  " .. title,
            Parent = topbar,
            ZIndex = 100
        })

        util.create("TextLabel", {
            Parent = main,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            Text = text,
            BackgroundTransparency = 1,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            TextWrapped = true
        })
        local close = util.create("TextButton", {
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(1, -20, 0.5, -7.5),
            BackgroundColor3 = loadedTheme.closeBtnColor,
            Parent = topbar,
            ZIndex = 4,
            Text = ""
        })
        util.roundify(close, 15)
        close.MouseButton1Down:Connect(function()
            shadow:Destroy()
            return "close"
        end)

        for i,btn in pairs(buttons) do
            local nbtn = util.create("TextButton", {
                Parent = main,
                BackgroundColor3 = loadedTheme.topbar,
                Font = loadedTheme["font"],
                FontSize = loadedTheme["fontSize"],
                Text = btn,
                TextColor3 = loadedTheme.secondaryForeground,
                Size = UDim2.new(1 / #buttons, -10 - 5*(i-1), 0, 25),
                AutoButtonColor = false,
                ClipsDescendants = true,
                Position = UDim2.new((1 / #buttons) * (i-1), 5 + 5*(i-1),1, -30)
            })
            print(nbtn.Position)
            util.roundify(nbtn, loadedTheme.widgetCornerRadius)
            nbtn.MouseButton1Down:Connect(function()
                callback(btn)
                local circleEffect = util.create("Frame", {
                    Parent = nbtn,
                    BackgroundColor3 = Color3.new(1,1,1),
                    Size = UDim2.new(0,1,0,1),
                    Position = UDim2.new(0, mouse.X - nbtn.AbsolutePosition.X, 0, mouse.Y - nbtn.AbsolutePosition.Y),
                    AnchorPoint = Vector2.new(0.5,0.5)
                })
                util.create("UICorner", {
                    Parent = circleEffect,
                    CornerRadius = UDim.new(1,0)
                })
                task.spawn(function()
                    for j = 0,40 do
                        circleEffect.Size += UDim2.new(0,25,0,25)
                        circleEffect.BackgroundTransparency = j / 40
                        task.wait()
                    end
                    circleEffect:Destroy()
                end)
            end)
        end
        return {
            shadow,
            destroy = function()
                shadow:Destroy()
            end
        }
    end,
    newNotif = function(type_, title, msg)
        for _,v in pairs(root:GetChildren()) do
            if v:FindFirstChild("Notif") then
                v.pos.Value -= 100
            end
        end
        local border = util.create("Frame", {
            Size = UDim2.new(0, 404, 0, 77),
            Position = UDim2.new(1, 0, 1, -100),
            Parent = root,
            Name = "Notif",
            ZIndex = 2,
            BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1
        })
        util.roundify(border, loadedTheme.cornerRadius)
        local shadow = util.addShadow(border, loadedTheme.shadowStrength)
        shadow.Name = "Notif"
        local pos = util.create("IntValue", {
            Value = -100,
            Parent = shadow,
            Name = "pos"
        })

        local colors = {
            ERR = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 0, 0))
            }),
            OK = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 121, 0))
            }),
            WARN = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(121, 121, 0))
            }),
            INFO = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 183, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 86, 136))
            }),
            MSG = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 212)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(153, 0, 255))
            }),
        }

        local gradient = util.create("UIGradient", {
            Color = colors[type_],
            Parent = border,
            Rotation = 45
        })

        task.spawn(function()
            while true do
                gradient.Rotation += 1
                task.wait()
            end
        end)
        local hover = util.create("Frame", {
            Parent = border,
            BackgroundColor3 = loadedTheme.topbar,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2)
        })
        util.roundify(hover, loadedTheme.cornerRadius)

        util.create("TextLabel", {
            Parent = hover,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 0),
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Text = "  " .. title,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
        })

        util.create("TextLabel", {
            Parent = hover,
            Size = UDim2.new(1, -2, 1, -22),
            Position = UDim2.new(0, 1, 0, 21),
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.secondaryForeground,
            Text = "  " .. msg,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        })
        shadow:TweenPosition(UDim2.new(1, -404, 0, border.AbsolutePosition.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
        task.spawn(function()
            while task.wait() do
                shadow:TweenPosition(UDim2.new(1, -404, 1, pos.Value), Enum.EasingDirection.InOut, Enum.EasingStyle.Quart, 0.25, false)
            end
        end)
        task.delay(5, function()
            shadow:TweenPosition(UDim2.new(1, 0, 0, border.AbsolutePosition.Y), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.25, true)
            task.wait(0.25)
            shadow:Destroy()
        end)
    end,
    addSeparator = function(category)
        local bg = util.create("Frame", {
            Parent = category,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 5, 0, util.getPos(category))
        })
        local a = util.create("Frame", {
            Parent = bg,
            BackgroundColor3 = loadedTheme.secondaryForeground,
            Size = UDim2.new(1, -10, 0, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, -5, 0.5, 0),
            BorderSizePixel = 0
        })
        return {
            bg
        }
    end,
    addNamedSeparator = function(category, name)
        local bg = util.create("Frame", {
            Parent = category,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 5, 0, util.getPos(category))
        })
        local a = util.create("Frame", {
            Parent = bg,
            BackgroundColor3 = loadedTheme.secondaryForeground,
            Size = UDim2.new(1, -10, 0, 1),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, -5, 0.5, 0),
            BorderSizePixel = 0
        })
        local bounds = game:GetService("TextService"):GetTextSize(name, 14, loadedTheme["font"], Vector2.new(math.huge, math.huge))
        local b = util.create("TextLabel", {
            Text = name,
            Size = UDim2.new(0, bounds.X + 4, 0, 14),
            AnchorPoint = Vector2.new(0.5, 0.5),
            TextColor3 = loadedTheme.secondaryForeground,
            Font = loadedTheme["font"],
            FontSize = Enum.FontSize.Size14,
            Parent = bg,
            BackgroundColor3 = loadedTheme["category"]["useCustomColors"] and loadedTheme["category"]["bgColor"] or loadedTheme.topbar,
            Position = UDim2.new(0.5, 0, 0.5, 0),
            BorderSizePixel = 0
        })
        return {
            bg,
            setName = function(n)
                b.Text = n
            end
        }
    end,
    addRichLabel = function(category, text, font, fontSize, textColor, bgColor, height, canvasSize, isCodePreview, codeTokens, customCodeTheme, editable)
        codeTokens = codeTokens or util.luaTokens
        local codeTheme = customCodeTheme or loadedTheme.syntaxHighlighting
        local bg = util.create("Frame", {
            Parent = category,
            BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
            Size = UDim2.new(1, 0, 0, 25 * height),
            Position = UDim2.new(0,0,0,util.getPos(category)),
        })
        util.roundify(bg, loadedTheme.widgetCornerRadius)
        local scroller = util.create("ScrollingFrame", {
            Parent = bg,
            Size = UDim2.new(1, -10, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BorderSizePixel = 0,
            CanvasSize = canvasSize,
            BackgroundTransparency = 1
        })
        local _t = "TextLabel"
        if editable then _t = "TextBox" end
        local txt = util.create(_t, {
            Parent = scroller,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = text,
            Font = (isCodePreview and Enum.Font.Code) or (font and font) or (loadedTheme.font),
            FontSize = fontSize,
            TextColor3 = (isCodePreview and codeTheme.foreground) or textColor,
            BackgroundColor3 = (isCodePreview and codeTheme.background) or bgColor,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        if editable then txt.ClearTextOnFocus = false; txt.MultiLine = true end

        local keywords, functions, comments, strings, numbers, special, operators, globals, lines, _pairs
        local function updateLineCount()
            lines.Text = ""
            local _,c = string.gsub(txt.Text, "\n", "")
            for i = 1, c + 1 do
                lines.Text ..= tostring(i) .. "\n"
            end
        end
        local function updatePairs()
            _pairs:ClearAllChildren()
            local openings = {"do", "then", "{", "[", "(", "else", "elseif", "function"}
            local endings = {"end", "}", "]", ")"}
            local matches = {
                ["do"] = "end",
                ["then"] = "end",
                ["else"] = "end",
                ["function"] = "end",
                ["{"] = "}",
                ["["] = "]",
                ["("] = ")"
            }
            local activeOpenings = 0
            for lineNum, line in pairs(string.split(txt.Text, "\n")) do
                local _openings = {}
                local hasOpening = false
                for _, _opening in pairs(openings) do
                    if string.find(line, _opening, 1, true) then
                        table.insert(_openings, _opening)
                        hasOpening = true
                    end
                end
                local _endings = {}
                local hasEnding = false
                for _, _ending in pairs(endings) do
                    if string.find(line, _ending, 1, true) then
                        table.insert(_endings, _ending)
                        hasEnding = true
                    end
                end
                local sy
                lineNum += 3
                sy = game:GetService("TextService"):GetTextSize(string.rep("a\n", math.clamp(lineNum - 2, 0, math.huge)), tonumber(string.sub(fontSize.Name, 5)), Enum.Font.Code, Vector2.new(math.huge, math.huge)).Y + 4
                local oneSy = (sy-4) / lineNum
                local off = game:GetService("TextService"):GetTextSize(string.rep("a\n", 2), tonumber(string.sub(fontSize.Name, 5)), Enum.Font.Code, Vector2.new(math.huge, math.huge)).Y + 4
                if #_openings == #_endings then
                    local __pairs = 0
                    for i = 1, #_openings do
                        if table.find(_endings, matches[_openings[i]]) then
                            __pairs += 1
                        end
                    end
                    if __pairs == #_openings and hasOpening then
                        local _line = util.create("Frame", {
                            BackgroundColor3 = codeTheme.foreground,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 1, 0, sy / (lineNum - 2)),
                            Position = UDim2.new(0.5, 0, 0, sy - off),
                            AnchorPoint = Vector2.new(0.5, 0),
                            Parent = _pairs
                        })
                        continue
                    end
                end
                for _, _opening in pairs(_openings) do
                    if _opening ~= "else" then
                        activeOpenings += 1
                    end
                    if _opening == "elseif" then
                        activeOpenings -= 2
                    end
                end
                for _, _ending in pairs(_endings) do
                    activeOpenings -= 1
                    if activeOpenings < 0 then activeOpenings = 0 end
                end
                if hasOpening then
                    local block = util.create("Frame", {
                        BackgroundColor3 = codeTheme.foreground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 6, 0, 6),
                        Position = UDim2.new(0.5, 0, 0, sy + oneSy / 2 - off),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Parent = _pairs
                    })
                    if activeOpenings > 0 then
                        local _line = util.create("Frame", {
                            BackgroundColor3 = codeTheme.foreground,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 1, 1, 0),
                            Position = UDim2.new(0.5, 0, 1, 0),
                            AnchorPoint = Vector2.new(0.5, 0),
                            Parent = block
                        })
                    end
                elseif activeOpenings > 0 then
                    local _line = util.create("Frame", {
                        BackgroundColor3 = codeTheme.foreground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 1, 0, oneSy + 4),
                        Position = UDim2.new(0.5, 0, 0, sy - off + 2),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Parent = _pairs
                    })
                    if hasEnding then
                        local _line = util.create("Frame", {
                            BackgroundColor3 = codeTheme.foreground,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0.5, 0, 0, 1),
                            Position = UDim2.new(0.75, 0, 0, sy - off + oneSy / 1.5),
                            AnchorPoint = Vector2.new(0.5, 0),
                            Parent = _pairs
                        })
                    end
                elseif hasEnding then
                    util.create("Frame", {
                        BackgroundColor3 = codeTheme.foreground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0, 1, 0, oneSy / 2 + 2),
                        Position = UDim2.new(0.5, 0, 0, sy - off),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Parent = _pairs
                    })
                    util.create("Frame", {
                        BackgroundColor3 = codeTheme.foreground,
                        BorderSizePixel = 0,
                        Size = UDim2.new(0.5, 0, 0, 1),
                        Position = UDim2.new(0.75, 0, 0, sy - off + oneSy / 1.5),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Parent = _pairs
                    })
                end
            end
        end
        if isCodePreview then
            local function createWithRef(ref, properties) local r = ref:clone() for k,v in properties do r[k] = v end r.Parent = ref.Parent return r end
            local _,c = string.gsub(txt.Text, "\n", "")
            local sx = game:GetService("TextService"):GetTextSize(c, tonumber(string.sub(fontSize.Name, 5)), Enum.Font.Code, Vector2.new(math.huge, math.huge)).X + 4
            txt.Size -= UDim2.new(0, sx + 10, 0, 0)
            txt.Position += UDim2.new(0, sx + 10, 0, 0)
            lines = createWithRef(txt, {
                Parent = scroller,
                Size = UDim2.new(0, sx, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = ""
            })
            updateLineCount()
            _pairs = createWithRef(txt, {
                Parent = scroller,
                Size = UDim2.new(0, 10, 1, 0),
                Position = UDim2.new(0, sx, 0, 0),
                Text = ""
            })
            updatePairs()
            keywords = util.create("TextLabel", { -- local, if, then, end, etc
                Parent = txt,
                TextColor3 = codeTheme.keywords,
                Text = "",
                BackgroundTransparency = 1,
                ZIndex = 5,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Font = (isCodePreview and Enum.Font.Code) or (font and font) or (loadedTheme.font),
                FontSize = fontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top
            })
            functions = createWithRef(keywords, { -- somefunc()
                TextColor3 = codeTheme.functions,
                ZIndex = 4
            })
            comments = createWithRef(keywords, { -- -- abc
                TextColor3 = codeTheme.comments
            })
            strings = createWithRef(keywords, { -- "amogus" 'sus' [[amogus sus]]
                TextColor3 = codeTheme.strings
            })
            numbers = createWithRef(keywords, { -- 123, true, nil
                TextColor3 = codeTheme.numbers
            })
            globals = createWithRef(keywords, { -- UDim2.new, table.insert, etc
                TextColor3 = codeTheme.globals
            })
            special = createWithRef(keywords, { -- UDim2.new, table.insert, etc
                TextColor3 = codeTheme.special
            })
            operators = createWithRef(keywords, { -- +, -, #, etc
                TextColor3 = codeTheme.operators
            })
        end

        local function advance(t, n)
            for _,v in pairs(t) do
                v.Text ..= type(n) == "number" and string.rep(" ", n) or (((n == "\n" or n == "\t") and n) or " ")
            end
        end

        local function _highlight()
            keywords.Text = ""
            functions.Text = ""
            comments.Text = ""
            strings.Text = ""
            numbers.Text = ""
            globals.Text = ""
            special.Text = ""
            operators.Text = ""
            txt.Text = string.gsub(txt.Text, "\t", "    ")
            txt.Text ..= ""
            local i = 1
            while i < string.len(txt.Text) do
                local chr = string.sub(txt.Text, i, i)
                if chr == nil then break end
                if string.find("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", chr, 1, true) then
                    local buf = ""
                    while i < string.len(txt.Text) and chr and string.find("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_1234567890", chr, 1, true) do
                        buf ..= chr
                        i += 1
                        chr = string.sub(txt.Text, i, i)
                        advance({
                            comments, strings, operators
                        }, 1)
                    end
                    i -= 1
                    local found = false
                    for _,keyword in pairs(codeTokens.keywords) do
                        if buf == keyword then
                            found = true
                            keywords.Text ..= buf
                            break
                        end
                    end
                    if not found then
                        advance({keywords}, string.len(buf))
                    end
                    found = false
                    for _,glob in pairs(codeTokens.globals) do
                        if buf == glob then
                            found = true
                            globals.Text ..= buf
                            break
                        end
                    end
                    if not found then
                        advance({globals}, string.len(buf))
                    end
                    found = false
                    for _,_special in pairs(codeTokens.special) do
                        if buf == _special then
                            found = true
                            special.Text ..= buf
                            break
                        end
                    end
                    if not found then
                        advance({special}, string.len(buf))
                    end
                    if i < string.len(txt.Text) and string.sub(txt.Text, i+1, i+1) == "(" then
                        functions.Text ..= buf
                    else
                        advance({functions}, string.len(buf))
                    end
                    if buf == "nil" or buf == "true" or buf == "false" then
                        numbers.Text ..= buf
                    else
                        advance({numbers}, string.len(buf))
                    end
                elseif i < string.len(txt.Text) and chr == "-" and string.sub(txt.Text, i+1, i+1) == "-" then
                    advance({keywords, functions, strings, numbers, special, operators, globals}, 2)
                    comments.Text ..= "--"
                    i += 2
                    chr = string.sub(txt.Text, i, i)
                    local commentLen = 0
                    local isMultiLine = false
                    while true do
                        comments.Text ..= chr
                        advance({keywords, functions, strings, numbers, special, operators, globals}, chr)
                        if i < string.len(txt.Text) and chr == "[" and string.sub(txt.Text, i+1, i+1) == "[" then
                            isMultiLine = true
                        end
                        if i < string.len(txt.Text) and chr == "]" and string.sub(txt.Text, i+1, i+1) == "]" and isMultiLine then
                            comments.Text ..= "]"
                            i += 2
                            break
                        end
                        i += 1
                        chr = string.sub(txt.Text, i, i)
                        commentLen += 1
                        if commentLen == 10000 then
                            break
                        end
                        if chr == "\n" and not isMultiLine then break end
                    end
                    i -= 1
                elseif string.find("1234567890", chr, 1, true) then
                    if i > 1 and string.find("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_", string.sub(txt.Text, i-1, i-1), 1, true) then
                        i += 1
                        advance({
                            keywords, functions, comments, strings, special, operators, globals, numbers
                        }, 1)
                        continue
                    end
                    local buf = ""
                    while i < string.len(txt.Text) and chr and string.find("1234567890", chr, 1, true) do
                        buf ..= chr
                        i += 1
                        chr = string.sub(txt.Text, i, i)
                        advance({
                            keywords, functions, comments, strings, special, operators, globals
                        }, 1)
                    end
                    i -= 1
                    numbers.Text ..= buf
                elseif chr == '"' or chr == "'" then
                    local ending = chr
                    strings.Text ..= ending
                    i += 1
                    chr = string.sub(txt.Text, i, i)
                    local foundEnd = false
                    while i < string.len(txt.Text) and chr and chr ~= ending do
                        strings.Text ..= chr
                        advance({
                            keywords, functions, comments, special, operators, globals, numbers
                        }, chr)
                        i += 1
                        chr = string.sub(txt.Text, i, i)
                        if chr == ending then foundEnd = true end
                    end
                    if foundEnd then
                        strings.Text ..= ending
                    end
                    chr = string.sub(txt.Text, i, i)
                    advance({
                        keywords, functions, comments, special, operators, globals, numbers
                    }, 2)
                elseif string.find(codeTokens.operators, chr, 1, true) then
                    operators.Text ..= chr
                    advance({
                        keywords, functions, comments, strings, special, globals, numbers
                    }, chr)
                else
                    advance({
                        keywords, functions, comments, strings, special, operators, globals, numbers
                    }, chr)
                end
                i += 1
            end
        end
        if editable then
            txt.Changed:Connect(function(property)
                if property == "Text" then
                    _highlight()
                    updatePairs()
                    updateLineCount()
                end
            end)
        end
        return {
            bg,
            highlight = _highlight,
            setText = function(_txt)
                txt.Text = _txt
            end,
            getText = function()
                return txt.Text
            end,
            setFont = function(font)
                txt.Font = isCodePreview and Enum.Font.Code or font
            end,
            setFontSize = function(fontSize)
                txt.FontSize = fontSize
            end,
            setCanvasSize = function(size)
                scroller.CanvasSize = size
            end,
            updateLineCount = updateLineCount,
            updatePairs = updatePairs,
            disable = function()
                util.disable(bg)
            end,
            enable = function()
                util.enable(bg)
            end
        }
    end,
    addContextMenu = function(widget, optionTree)
        widget = widget[1]
        local border
        local function openMenu()
            if mouse.X > widget.AbsolutePosition.X and mouse.Y > widget.AbsolutePosition.Y and mouse.X < widget.AbsolutePosition.X + widget.AbsoluteSize.X and mouse.Y < widget.AbsolutePosition.Y + widget.AbsoluteSize.Y then
                if root:FindFirstChild("Ctx") then root.Ctx:Destroy() end
                border = util.create("Frame", {
                    Size = UDim2.new(0, 200, 0, 0),
                    Position = UDim2.new(0, mouse.X, 0, mouse.Y),
                    Parent = root,
                    Name = "Ctx",
                    ZIndex = 1,
                    BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1,
                    ClipsDescendants = true
                })
                util.roundify(border, loadedTheme.widgetCornerRadius)
                local gradient = util.create("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, loadedTheme.accent),
                        ColorSequenceKeypoint.new(1, loadedTheme.secondaryAccent)
                    }),
                    Parent = border,
                    Rotation = 45
                })
                task.spawn(function()
                    while true do
                        gradient.Rotation += 1
                        task.wait()
                    end
                end)
                local bg = util.create("Frame", {
                    Parent = border,
                    BackgroundColor3 = loadedTheme.widget.useCustomColors and loadedTheme.widget.primaryBg or loadedTheme.background,
                    Size = UDim2.new(1, -2, 1, -2),
                    Position = UDim2.new(0, 1, 0, 1),
                })
                util.roundify(bg, loadedTheme.widgetCornerRadius)
                util.create("UIListLayout", {
                    Parent = bg
                })
                local even = true
                for btn,entry in pairs(optionTree) do
                    local _btn = util.create("TextButton", {
                        Parent = bg,
                        Size = UDim2.new(1,0,0,20),
                        BackgroundTransparency = 1,
                        Font = loadedTheme.font,
                        FontSize = Enum.FontSize.Size14,
                        TextColor3 = loadedTheme.foreground,
                        Text = btn,
                        ClipsDescendants = true
                    })
                    if entry[2] ~= nil then
                        util.create("ImageLabel", {
                            Parent = _btn,
                            Size = UDim2.new(0,20,0,20),
                            Position = UDim2.new(0, 0, 0, 0),
                            BackgroundTransparency = 1,
                            Image = entry[2]
                        })
                    end
                    local function click(x,y)
                        entry[1]()
                        local circleEffect = util.create("Frame", {
                            Parent = _btn,
                            BackgroundColor3 = Color3.new(1,1,1),
                            Size = UDim2.new(0,1,0,1),
                            Position = UDim2.new(0, x, 0, y),
                            AnchorPoint = Vector2.new(0.5,0.5)
                        })
                        util.create("UICorner", {
                            Parent = circleEffect,
                            CornerRadius = UDim.new(1,0)
                        })
                        task.spawn(function()
                            for i = 0,40 do
                                circleEffect.Size += UDim2.new(0,25,0,25)
                                circleEffect.BackgroundTransparency = i / 40
                                task.wait()
                            end
                            circleEffect:Destroy()
                        end)
                    end
                    _btn.MouseButton1Down:Connect(function()
                        click(mouse.X - _btn.AbsolutePosition.X, mouse.Y - _btn.AbsolutePosition.Y)
                    end)
                    even = not even
                end
                local len = 0
                for _ in optionTree do len += 1 end
                border:TweenSize(UDim2.new(0, 200, 0, len * 20 + 2), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true)
            end
        end
        local function close()
            if not border then return end
            border:TweenSize(UDim2.new(0, 200, 0, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.1, true, function(c)
                border:Destroy()
                border = nil
            end)
        end
        mouse.Button2Down:Connect(openMenu)
        mouse.Button1Down:Connect(close)
        if widget:IsA("TextButton") then
            widget.MouseButton2Down:Connect(openMenu)
            widget.MouseButton1Down:Connect(close)
        end

        for _,desc in pairs(widget:GetDescendants()) do -- Make sure the entire widget is interactable
            if desc:IsA("TextButton") then
                desc.MouseButton2Down:Connect(openMenu)
                desc.MouseButton1Down:Connect(close)
            end
            if desc:IsA("TextBox") then
                desc.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton2 then
                        desc:ReleaseFocus()
                        openMenu()
                    end
                end)
                desc.Focused:Connect(close)
            end
        end
    end,
    newKeyPrompt = function(title, icon, callback)
        local width = 200
        local height = 120
        local border = util.create("Frame", {
            Size = UDim2.new(0, width + 4, 0, height + 4),
            Position = UDim2.new(0.5,-width/2,0.5,-height/2),
            Parent = root,
            Name = "Carbon",
            ZIndex = 1,
            BackgroundTransparency = loadedTheme.carbonBorderEnabled and 0 or 1
        })

        util.addShadow(border, loadedTheme.shadowStrength)
        util.makeDraggable(border)
        util.roundify(border, loadedTheme.cornerRadius)

        local gradient = util.create("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, loadedTheme.accent),
                ColorSequenceKeypoint.new(1, loadedTheme.secondaryAccent)
            }),
            Parent = border,
            Rotation = 45
        })
        task.spawn(function()
            while true do
                gradient.Rotation += 1
                task.wait()
            end
        end)

        local main = util.create("Frame", {
            Size = UDim2.new(0, width, 0, height),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundColor3 = loadedTheme.background,
            Parent = border,
            Name = "main"
        })
        util.roundify(main, loadedTheme.cornerRadius)

        local topbar = util.create("Frame", {
            Size = UDim2.new(0, width, 0, 30),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = main
        })
        util.roundify(topbar, loadedTheme.cornerRadius)
        util.create("Frame", {
            Size = UDim2.new(0, width, 0, 15),
            Position = UDim2.new(0, 0, 0, 15),
            BackgroundColor3 = loadedTheme.topbar,
            Parent = topbar,
            BorderSizePixel = 0,
            ZIndex = 2
        })

        util.create("TextLabel", {
            Size = UDim2.new(0, width-(icon and 30 or 0), 0, 30),
            Position = UDim2.new(0, icon and 30 or 0, 0, 0),
            BackgroundTransparency = 1,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            TextColor3 = loadedTheme.foreground,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = "  " .. title,
            Parent = topbar,
            ZIndex = 100
        })

        local txt = util.create("TextBox", {
            Size = UDim2.new(0, 170, 0, 20),
            Position = UDim2.new(0, 15, 0, 45),
            BackgroundColor3 = loadedTheme.topbar,
            Text = "Key",
            TextColor3 = loadedTheme.foreground,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Parent = main
        })
        util.roundify(txt, loadedTheme.widgetCornerRadius)

        local verify = util.create("TextButton", {
            Size = UDim2.new(0, 100, 0, 20),
            Position = UDim2.new(0, 50, 0, 75),
            BackgroundColor3 = loadedTheme.topbar,
            Text = "Verify",
            TextColor3 = loadedTheme.foreground,
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Parent = main,
            ClipsDescendants = true
        })
        util.roundify(verify, loadedTheme.widgetCornerRadius)

        local errMsg = util.create("TextButton", {
            Size = UDim2.new(1, 0, 0, 25),
            Position = UDim2.new(0, 0, 0, 95),
            BackgroundTransparency = 1,
            Text = "",
            TextTransparency = 1,
            TextColor3 = Color3.new(1, 0, 0),
            Font = loadedTheme["font"],
            FontSize = loadedTheme["fontSize"],
            Parent = main
        })

        verify.MouseButton1Down:Connect(function()
            callback(txt.Text)
            local circleEffect = util.create("Frame", {
                Parent = verify,
                BackgroundColor3 = Color3.new(1,1,1),
                Size = UDim2.new(0,1,0,1),
                Position = UDim2.new(0, mouse.X - verify.AbsolutePosition.X, 0, mouse.Y - verify.AbsolutePosition.Y),
                AnchorPoint = Vector2.new(0.5,0.5)
            })
            util.create("UICorner", {
                Parent = circleEffect,
                CornerRadius = UDim.new(1,0)
            })
            task.spawn(function()
                for i = 0,40 do
                    circleEffect.Size += UDim2.new(0,7,0,7)
                    circleEffect.BackgroundTransparency = i / 40
                    task.wait()
                end
                circleEffect:Destroy()
            end)
        end)

        return {
            displayMessage = function(msg, txtCol)
                errMsg.Text = msg
                errMsg.TextColor3 = txtCol
                task.spawn(function()
                    for i = 10, 0, -1 do
                        errMsg.TextTransparency = i / 10
                        task.wait(0.025)
                    end
                end)
                task.delay(2, function()
                    for i = 0, 10 do
                        errMsg.TextTransparency = i / 10
                        task.wait(0.025)
                    end
                end)
            end
        }
    end,
    util = util,
    loadTheme = loadTheme, -- Might move into util, though it's not as clean (util is mostly reserved for developer shit)
    loadThemeFromFile = loadThemeFromFile
}

if gethui and gethui():FindFirstChild(root.Name) then
    gethui():FindFirstChild(root.Name):Destroy()
elseif game.CoreGui:FindFirstChild(root.Name) then
    game.CoreGui:FindFirstChild(root.Name):Destroy()
end
root.Parent = gethui and gethui() or game.CoreGui

return carbon