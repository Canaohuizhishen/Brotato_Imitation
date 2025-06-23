var k = 1.1
function lightenColor(hexColor, factor) {
    // 解析十六进制颜色
    const r = parseInt(hexColor.substr(1, 2), 16)
    const g = parseInt(hexColor.substr(3, 2), 16)
    const b = parseInt(hexColor.substr(5, 2), 16)

    // 调整 RGB 值
    const lighten = (c) => Math.min(255, Math.floor(c * factor))

    const rLightened = lighten(r)
    const gLightened = lighten(g)
    const bLightened = lighten(b)

    // 转换回十六进制
    const toHex = (c) => c.toString(16).padStart(2, '0')

    return `#${toHex(rLightened)}${toHex(gLightened)}${toHex(bLightened)}`
}

function getBorderColor(grade) {
    const colors = {
        1: "#000000",
        2: "#52ADE8",
        3: "#974FDD",
        4: "#E73535"
    }
    return lightenColor(colors[grade] || "#000000", k)
}

function getButtonColor(grade) {
    const colors = {
        1: "#191919",
        2: "#27363D",
        3: "#272231",
        4: "#392121"
    }
    return lightenColor(colors[grade] || "#000000", k)
}

function getBackgroundColor(grade) {
    const colors = {
        1: "#000000",
        2: "#0F2028",
        3: "#100A18",
        4: "#240909"
    }
    return lightenColor(colors[grade] || "#000000", k)
}

function getImageBackgroundColor(grade) {
    const colors = {
        1: "#323232",
        2: "#3E4C52",
        3: "#3F3A48",
        4: "#4F3939"
    }
    return lightenColor(colors[grade] || "#000000", k)
}
