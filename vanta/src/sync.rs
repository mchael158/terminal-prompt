use std::fs;
use std::io;
use std::path::Path;

use crate::palette::VANTA;

pub fn write_terminal_files(root: &Path) -> io::Result<()> {
    fs::write(root.join("linux/kitty.conf"), kitty())?;
    fs::write(root.join("linux/alacritty.toml"), alacritty())?;
    fs::write(root.join("linux/foot.ini"), foot())?;
    fs::write(root.join("windows-terminal-fragment.json"), windows_terminal())?;
    patch_ide(root.join("IDE.json"))?;
    Ok(())
}

fn kitty() -> String {
    let a = &VANTA.ansi;
    format!(
        r#"# terminal-prompt
# Gerado por `vanta sync`. A paleta mora em vanta/src/palette.rs.
foreground {fg}
background {bg}
background_opacity 0
cursor {cursor}
cursor_text_color {bg}
selection_background {sel}
selection_foreground {sel_text}

color0  {c0}
color1  {c1}
color2  {c2}
color3  {c3}
color4  {c4}
color5  {c5}
color6  {c6}
color7  {c7}
color8  {c8}
color9  {c9}
color10 {c10}
color11 {c11}
color12 {c12}
color13 {c13}
color14 {c14}
color15 {c15}

font_family JetBrainsMono Nerd Font
font_size 13.0
"#,
        fg = VANTA.foreground.css(),
        bg = VANTA.background.css(),
        cursor = VANTA.cursor.css(),
        sel = VANTA.selection.css(),
        sel_text = VANTA.selection_text.css(),
        c0 = a[0].css(),
        c1 = a[1].css(),
        c2 = a[2].css(),
        c3 = a[3].css(),
        c4 = a[4].css(),
        c5 = a[5].css(),
        c6 = a[6].css(),
        c7 = a[7].css(),
        c8 = a[8].css(),
        c9 = a[9].css(),
        c10 = a[10].css(),
        c11 = a[11].css(),
        c12 = a[12].css(),
        c13 = a[13].css(),
        c14 = a[14].css(),
        c15 = a[15].css(),
    )
}

fn alacritty() -> String {
    let a = &VANTA.ansi;
    format!(
        r#"# terminal-prompt
# Gerado por `vanta sync`. A paleta mora em vanta/src/palette.rs.

[window]
opacity = 0.0

[font]
size = 13

[font.normal]
family = "JetBrainsMono Nerd Font"
style = "Regular"

[colors.primary]
foreground = "{fg}"
background = "{bg}"

[colors.cursor]
cursor = "{cursor}"

[colors.selection]
background = "{sel}"
foreground = "{sel_text}"

[colors.normal]
black = "{c0}"
red = "{c1}"
green = "{c2}"
yellow = "{c3}"
blue = "{c4}"
magenta = "{c5}"
cyan = "{c6}"
white = "{c7}"

[colors.bright]
black = "{c8}"
red = "{c9}"
green = "{c10}"
yellow = "{c11}"
blue = "{c12}"
magenta = "{c13}"
cyan = "{c14}"
white = "{c15}"
"#,
        fg = VANTA.foreground.css(),
        bg = VANTA.background.css(),
        cursor = VANTA.cursor.css(),
        sel = VANTA.selection.css(),
        sel_text = VANTA.selection_text.css(),
        c0 = a[0].css(),
        c1 = a[1].css(),
        c2 = a[2].css(),
        c3 = a[3].css(),
        c4 = a[4].css(),
        c5 = a[5].css(),
        c6 = a[6].css(),
        c7 = a[7].css(),
        c8 = a[8].css(),
        c9 = a[9].css(),
        c10 = a[10].css(),
        c11 = a[11].css(),
        c12 = a[12].css(),
        c13 = a[13].css(),
        c14 = a[14].css(),
        c15 = a[15].css(),
    )
}

fn foot() -> String {
    let a = &VANTA.ansi;
    format!(
        r#"# terminal-prompt
# Gerado por `vanta sync`. A paleta mora em vanta/src/palette.rs.
font=JetBrainsMono Nerd Font:size=13
[colors]
alpha=0
foreground={fg}
background={bg}
cursor={cursor}
selection-foreground={sel_text}
selection-background={sel}
regular0={c0}
regular1={c1}
regular2={c2}
regular3={c3}
regular4={c4}
regular5={c5}
regular6={c6}
regular7={c7}
bright0={c8}
bright1={c9}
bright2={c10}
bright3={c11}
bright4={c12}
bright5={c13}
bright6={c14}
bright7={c15}
"#,
        fg = VANTA.foreground.bare(),
        bg = VANTA.background.bare(),
        cursor = VANTA.cursor.bare(),
        sel = VANTA.selection.bare(),
        sel_text = VANTA.selection_text.bare(),
        c0 = a[0].bare(),
        c1 = a[1].bare(),
        c2 = a[2].bare(),
        c3 = a[3].bare(),
        c4 = a[4].bare(),
        c5 = a[5].bare(),
        c6 = a[6].bare(),
        c7 = a[7].bare(),
        c8 = a[8].bare(),
        c9 = a[9].bare(),
        c10 = a[10].bare(),
        c11 = a[11].bare(),
        c12 = a[12].bare(),
        c13 = a[13].bare(),
        c14 = a[14].bare(),
        c15 = a[15].bare(),
    )
}

fn windows_terminal() -> String {
    let a = &VANTA.ansi;
    format!(
        r#"{{
  "profiles": {{
    "defaults": {{
      "font": {{
        "face": "JetBrainsMono Nerd Font",
        "size": 13
      }},
      "useAcrylic": true,
      "acrylicOpacity": 0,
      "colorScheme": "VANTA"
    }}
  }},
  "schemes": [
    {{
      "name": "VANTA",
      "background": "{bg}",
      "foreground": "{fg}",
      "cursorColor": "{cursor}",
      "selectionBackground": "{sel}",
      "black": "{c0}",
      "red": "{c1}",
      "green": "{c2}",
      "yellow": "{c3}",
      "blue": "{c4}",
      "purple": "{c5}",
      "cyan": "{c6}",
      "white": "{c7}",
      "brightBlack": "{c8}",
      "brightRed": "{c9}",
      "brightGreen": "{c10}",
      "brightYellow": "{c11}",
      "brightBlue": "{c12}",
      "brightPurple": "{c13}",
      "brightCyan": "{c14}",
      "brightWhite": "{c15}"
    }}
  ]
}}
"#,
        bg = VANTA.background.css(),
        fg = VANTA.foreground.css(),
        cursor = VANTA.cursor.css(),
        sel = VANTA.selection.css(),
        c0 = a[0].css(),
        c1 = a[1].css(),
        c2 = a[2].css(),
        c3 = a[3].css(),
        c4 = a[4].css(),
        c5 = a[5].css(),
        c6 = a[6].css(),
        c7 = a[7].css(),
        c8 = a[8].css(),
        c9 = a[9].css(),
        c10 = a[10].css(),
        c11 = a[11].css(),
        c12 = a[12].css(),
        c13 = a[13].css(),
        c14 = a[14].css(),
        c15 = a[15].css(),
    )
}

fn patch_ide(path: impl AsRef<Path>) -> io::Result<()> {
    let path = path.as_ref();
    if !path.exists() {
        return Ok(());
    }
    let mut text = fs::read_to_string(path)?;
    let pairs = [
        ("terminal.foreground", VANTA.foreground),
        ("terminalCursor.foreground", VANTA.cursor),
        ("terminal.ansiBlack", VANTA.ansi[0]),
        ("terminal.ansiRed", VANTA.ansi[1]),
        ("terminal.ansiGreen", VANTA.ansi[2]),
        ("terminal.ansiYellow", VANTA.ansi[3]),
        ("terminal.ansiBlue", VANTA.ansi[4]),
        ("terminal.ansiMagenta", VANTA.ansi[5]),
        ("terminal.ansiCyan", VANTA.ansi[6]),
        ("terminal.ansiWhite", VANTA.ansi[7]),
        ("terminal.ansiBrightBlack", VANTA.ansi[8]),
        ("terminal.ansiBrightRed", VANTA.ansi[9]),
        ("terminal.ansiBrightGreen", VANTA.ansi[10]),
        ("terminal.ansiBrightYellow", VANTA.ansi[11]),
        ("terminal.ansiBrightBlue", VANTA.ansi[12]),
        ("terminal.ansiBrightMagenta", VANTA.ansi[13]),
        ("terminal.ansiBrightCyan", VANTA.ansi[14]),
        ("terminal.ansiBrightWhite", VANTA.ansi[15]),
    ];
    for (key, color) in pairs {
        text = replace_json_string(&text, key, &color.css());
    }
    fs::write(path, text)
}

fn replace_json_string(text: &str, key: &str, value: &str) -> String {
    let needle = format!("\"{key}\"");
    let Some(start) = text.find(&needle) else {
        return text.to_string();
    };
    let Some(colon) = text[start + needle.len()..].find(':') else {
        return text.to_string();
    };
    let after = start + needle.len() + colon + 1;
    let Some(open) = text[after..].find('"') else {
        return text.to_string();
    };
    let value_at = after + open + 1;
    let Some(close) = text[value_at..].find('"') else {
        return text.to_string();
    };
    let mut out = String::with_capacity(text.len());
    out.push_str(&text[..value_at]);
    out.push_str(value);
    out.push_str(&text[value_at + close..]);
    out
}
