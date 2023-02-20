return {
    background = Color3.fromRGB(35, 40, 61),
    topbar = Color3.fromRGB(27, 30, 47),
    accent = Color3.fromRGB(255, 0, 212),
    secondaryAccent = Color3.fromRGB(153, 0, 255),
    foreground = Color3.fromRGB(161, 168, 204),
    secondaryForeground = Color3.fromRGB(161, 168, 204),

    cornerRadius = 12,
    widgetCornerRadius = 6,

    shadowStrength = 15,

    closeBtnColor = Color3.fromRGB(247, 118, 142),
    minimizeBtnColor = Color3.fromRGB(224,175,104),
    closeBtnText = "",
    minimizeBtnText = "",

    fontSize = Enum.FontSize.Size18,
    font = Enum.Font.Ubuntu,

    carbonBorderEnabled = true,
    robloxBorder = {
        window = {
            size = 0,
            color = Color3.fromRGB(140,140,140)
        }
    },
    category = {
        titleVisible = true,
        separatorVisible = true,
        useCustomColors = false,
        bgColor = Color3.fromRGB(30, 30, 30),
        widgetSpacing = 5,
        padding = {
            left = UDim.new(0, 5),
            right = UDim.new(0, 5),
            top = UDim.new(0, 5),
            bottom = UDim.new(0, 5),
        }
    },
    tab = {
        categorySpacing = 5,
        padding = {
            left = UDim.new(0, 5),
            right = UDim.new(0, 5),
            top = UDim.new(0, 5),
            bottom = UDim.new(0, 5),
        }
    },
    widget = {
        useCustomColors = false,
        primaryBg = Color3.fromRGB(40, 40, 40),
        secondaryBg = Color3.fromRGB(45, 45, 45),
        isSliderRound = true,
        border = {
            size = 0,
            color = Color3.fromRGB(120,120,120),
            borderType = "inner",
            useBorderOnExtras = true
        }
    },
    syntaxHighlighting = {
        keywords = Color3.fromHex("#bb9af7"),
        functions = Color3.fromHex("#7aa2f7"),
        comments = Color3.fromHex("#565f89"),
        strings = Color3.fromHex("#9ece6a"),
        numbers = Color3.fromHex("#ff9e64"),
        globals = Color3.fromHex("#7aa2f7"),
        special = Color3.fromHex("#2ac3de"),
        operators = Color3.fromHex("#73daca"),

        foreground = Color3.fromHex("#a9b1d6"),
        background = Color3.fromHex("#1a1b26"),
    }
}