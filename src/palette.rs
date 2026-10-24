#[derive(Clone, Copy)]
pub struct Rgb(pub u8, pub u8, pub u8);

impl Rgb {
    pub const fn hex(value: u32) -> Self {
        Self(
            ((value >> 16) & 0xff) as u8,
            ((value >> 8) & 0xff) as u8,
            (value & 0xff) as u8,
        )
    }

    pub fn css(self) -> String {
        format!("#{:02X}{:02X}{:02X}", self.0, self.1, self.2)
    }

    pub fn bare(self) -> String {
        format!("{:02X}{:02X}{:02X}", self.0, self.1, self.2)
    }

    pub fn paint(self, text: &str, bold: bool) -> String {
        if text.is_empty() {
            return String::new();
        }
        let weight = if bold { "1;" } else { "" };
        format!(
            "\x1b[{weight}38;2;{};{};{}m{text}\x1b[0m",
            self.0, self.1, self.2
        )
    }
}

pub struct Palette {
    pub background: Rgb,
    pub foreground: Rgb,
    pub cursor: Rgb,
    pub selection: Rgb,
    pub selection_text: Rgb,
    pub ansi: [Rgb; 16],
    pub blush: Rgb,
    pub flare: Rgb,
    pub hot: Rgb,
    pub scarlet: Rgb,
    pub crimson: Rgb,
    pub blood: Rgb,
    pub ember: Rgb,
    pub paper: Rgb,
    pub error: Rgb,
    pub warning: Rgb,
}

pub const VANTA: Palette = Palette {
    background: Rgb::hex(0x0A0E14),
    foreground: Rgb::hex(0xB7F6E8),
    cursor: Rgb::hex(0x3DFFE0),
    selection: Rgb::hex(0x2EE0C0),
    selection_text: Rgb::hex(0xE7FFF8),
    ansi: [
        Rgb::hex(0x123632),
        Rgb::hex(0xE1062C),
        Rgb::hex(0x2EE0C0),
        Rgb::hex(0xF5C542),
        Rgb::hex(0x0E7A68),
        Rgb::hex(0x24C8AE),
        Rgb::hex(0x7AF6DE),
        Rgb::hex(0xA8F0E2),
        Rgb::hex(0x0E5C52),
        Rgb::hex(0xFF4D6A),
        Rgb::hex(0x4AE8D0),
        Rgb::hex(0xFFE08A),
        Rgb::hex(0x1AD4B8),
        Rgb::hex(0x3ADCC4),
        Rgb::hex(0x8AF8E6),
        Rgb::hex(0xC8FFF4),
    ],
    blush: Rgb::hex(0xB7F6E8),
    flare: Rgb::hex(0x8AF8E6),
    hot: Rgb::hex(0x5AF0D4),
    scarlet: Rgb::hex(0x2EE0C0),
    crimson: Rgb::hex(0x14967E),
    blood: Rgb::hex(0x0E5C52),
    ember: Rgb::hex(0x3A9A8C),
    paper: Rgb::hex(0xE7FFF8),
    error: Rgb::hex(0xE1062C),
    warning: Rgb::hex(0xF5C542),
};
