use crate::palette::{Rgb, VANTA};

const VERBS: &[&str] = &[
    "Doc-tests",
    "Downloading",
    "Downloaded",
    "Compiling",
    "Checking",
    "Packaging",
    "Archiving",
    "Installing",
    "Generating",
    "Generated",
    "Replacing",
    "Removing",
    "Blocking",
    "Building",
    "Finished",
    "Updating",
    "Waiting",
    "Locking",
    "Running",
    "warning",
    "Fresh",
    "Dirty",
    "error",
];

pub fn style_line(line: &str) -> Option<String> {
    try_paint(line)
}

fn try_paint(line: &str) -> Option<String> {
    let (pad, body) = split_pad(line);
    if let Some((verb, rest)) = split_verb(body) {
        let mut out = VANTA.blood.paint(pad, false);
        out.push_str(&verb_color(verb).paint(verb, true));
        out.push_str(&paint_rest(verb, rest));
        return Some(out);
    }
    paint_test(line).or_else(|| paint_summary(line))
}

fn verb_color(verb: &str) -> Rgb {
    match verb {
        "Compiling" | "Building" => VANTA.scarlet,
        "Checking" | "Doc-tests" => VANTA.hot,
        "Downloading" | "warning" => VANTA.flare,
        "Downloaded" | "Fresh" => VANTA.blood,
        "Finished" => VANTA.paper,
        "Running" | "error" => VANTA.crimson,
        "Blocking" => VANTA.ember,
        _ => VANTA.hot,
    }
}

fn paint_rest(verb: &str, rest: &str) -> String {
    match verb {
        "Compiling" | "Checking" | "Building" | "Fresh" | "Downloading" | "Downloaded"
        | "Doc-tests" => paint_package(rest).unwrap_or_else(|| VANTA.blush.paint(rest, false)),
        "Finished" | "Running" => paint_quoted(verb, rest).unwrap_or_else(|| VANTA.blush.paint(rest, false)),
        _ => VANTA.blush.paint(rest, false),
    }
}

fn paint_package(rest: &str) -> Option<String> {
    let (gap, body) = split_pad(rest);
    if gap.is_empty() {
        return None;
    }
    let (name, after_name) = split_token(body)?;
    let (mid, after_mid) = split_pad(after_name);
    if mid.is_empty() {
        return None;
    }
    let (ver, tail) = split_token(after_mid)?;
    if !ver.starts_with('v') {
        return None;
    }
    let mut out = VANTA.blush.paint(gap, false);
    out.push_str(&VANTA.paper.paint(name, true));
    out.push_str(&VANTA.blush.paint(mid, false));
    out.push_str(&VANTA.flare.paint(ver, false));
    out.push_str(&VANTA.ember.paint(tail.trim_end(), false));
    Some(out)
}

fn paint_quoted(verb: &str, rest: &str) -> Option<String> {
    let (gap, body) = split_pad(rest);
    let inner = body.strip_prefix('`')?;
    let (quoted, tail) = inner.split_once('`')?;
    let ink = if verb == "Running" { VANTA.paper } else { VANTA.scarlet };
    let mut out = VANTA.blush.paint(gap, false);
    out.push_str(&VANTA.blood.paint("`", false));
    out.push_str(&ink.paint(quoted, true));
    out.push_str(&VANTA.blood.paint("`", false));
    out.push_str(&paint_tail(tail));
    Some(out)
}

fn paint_tail(tail: &str) -> String {
    const MARK: &str = " in ";
    let Some(at) = tail.rfind(MARK) else {
        return VANTA.blush.paint(tail, false);
    };
    let mut out = VANTA.blush.paint(&tail[..at], false);
    out.push_str(&VANTA.blood.paint(MARK, false));
    out.push_str(&VANTA.flare.paint(&tail[at + MARK.len()..], true));
    out
}

fn paint_test(line: &str) -> Option<String> {
    let (name, status) = line.rsplit_once(" ... ")?;
    if !name.starts_with("test ") {
        return None;
    }
    let ink = match status {
        "ok" => VANTA.flare,
        "FAILED" | "failed" => VANTA.crimson,
        "ignored" => VANTA.ember,
        _ => return None,
    };
    let mut out = VANTA.blush.paint(name, false);
    out.push_str(&VANTA.blood.paint(" ... ", false));
    out.push_str(&ink.paint(status, true));
    Some(out)
}

fn paint_summary(line: &str) -> Option<String> {
    let rest = line.strip_prefix("test result: ")?;
    let (word, tail) = rest.split_once(|c: char| !c.is_ascii_alphabetic())?;
    let ink = match word {
        "ok" => VANTA.flare,
        "FAILED" => VANTA.crimson,
        _ => return None,
    };
    let mut out = VANTA.blood.paint("test result: ", true);
    out.push_str(&ink.paint(word, true));
    out.push_str(&paint_tail(tail));
    Some(out)
}

fn split_pad(text: &str) -> (&str, &str) {
    let end = text
        .find(|c: char| !c.is_ascii_whitespace())
        .unwrap_or(text.len());
    (&text[..end], &text[end..])
}

fn split_token(text: &str) -> Option<(&str, &str)> {
    if text.is_empty() {
        return None;
    }
    let end = text
        .find(|c: char| c.is_ascii_whitespace())
        .unwrap_or(text.len());
    if end == 0 {
        return None;
    }
    Some((&text[..end], &text[end..]))
}

fn split_verb(body: &str) -> Option<(&str, &str)> {
    let verb = VERBS.iter().copied().find(|verb| {
        let Some(rest) = body.strip_prefix(verb) else {
            return false;
        };
        match rest.chars().next() {
            None => true,
            Some(ch) => !ch.is_ascii_alphanumeric(),
        }
    })?;
    Some((verb, &body[verb.len()..]))
}

#[cfg(test)]
mod tests {
    use super::style_line;

    fn paint_line(line: &str) -> String {
        style_line(line).unwrap_or_else(|| line.to_string())
    }

    #[test]
    fn compiling_uses_three_tones() {
        let line = paint_line("   Compiling byteflow-actors v0.9.17 (C:/src/byteflow)");
        assert!(line.contains("1;38;2;255;31;56mCompiling"));
        assert!(line.contains("1;38;2;255;228;230mbyteflow-actors"));
        assert!(line.contains("38;2;255;138;148mv0.9.17"));
        assert!(line.contains("38;2;160;64;80m (C:/src/byteflow)"));
    }

    #[test]
    fn finished_and_running_differ() {
        let finished = paint_line("    Finished `dev` profile [unoptimized] target(s) in 0.60s");
        let running = paint_line("     Running `target/debug/byteflow demo`");
        assert!(finished.contains("1;38;2;255;228;230mFinished"));
        assert!(finished.contains("1;38;2;255;31;56mdev"));
        assert!(running.contains("1;38;2;225;6;44mRunning"));
        assert!(running.contains("1;38;2;255;228;230mtarget/debug/byteflow demo"));
    }

    #[test]
    fn rustc_error_stays_crimson() {
        let line = paint_line("error[E0382]: borrow of moved value");
        assert!(line.contains("1;38;2;225;6;44merror"));
        assert!(line.contains("[E0382]: borrow of moved value"));
    }

    #[test]
    fn plain_lines_keep_their_text() {
        assert_eq!(paint_line("    |"), "    |");
        assert_eq!(paint_line("hello from the program"), "hello from the program");
    }

    #[test]
    fn tests_and_duration_are_marked() {
        let finished = paint_line("    Finished `dev` profile [unoptimized] target(s) in 0.60s");
        assert!(finished.contains("1;38;2;255;138;148m0.60s"));
        let ok = paint_line("test paint::tests::compiling_uses_three_tones ... ok");
        assert!(ok.contains("1;38;2;255;138;148mok"));
        let failed = paint_line("test result: FAILED. 0 passed; 1 failed; finished in 1s");
        assert!(failed.contains("1;38;2;225;6;44mFAILED"));
        assert!(failed.contains("1;38;2;255;138;148m1s"));
    }
}
