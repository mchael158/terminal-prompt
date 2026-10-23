//! Uma paleta só. O terminal, o cargo e os arquivos gerados leem daqui.

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
}

pub const VANTA: Palette = Palette {
    background: Rgb::hex(0x0A0E14),
    foreground: Rgb::hex(0xFFC2C6),
    cursor: Rgb::hex(0xFF0033),
    selection: Rgb::hex(0xFF1F38),
    selection_text: Rgb::hex(0xFFB4BA),
    ansi: [
        Rgb::hex(0x4A0610),
        Rgb::hex(0xE1062C),
        Rgb::hex(0xFF1F38),
        Rgb::hex(0xFF4D5A),
        Rgb::hex(0xC40024),
        Rgb::hex(0xFF2D4A),
        Rgb::hex(0xFF6B74),
        Rgb::hex(0xFF8A94),
        Rgb::hex(0x8E1020),
        Rgb::hex(0xFF0033),
        Rgb::hex(0xFF2A40),
        Rgb::hex(0xFF5C66),
        Rgb::hex(0xFF1744),
        Rgb::hex(0xFF4060),
        Rgb::hex(0xFF7A84),
        Rgb::hex(0xFFB4BA),
    ],
    blush: Rgb::hex(0xFFC2C6),
    flare: Rgb::hex(0xFF8A94),
    hot: Rgb::hex(0xFF4D5A),
    scarlet: Rgb::hex(0xFF1F38),
    crimson: Rgb::hex(0xE1062C),
    blood: Rgb::hex(0x8E1020),
    ember: Rgb::hex(0xA04050),
    paper: Rgb::hex(0xFFE4E6),
};
