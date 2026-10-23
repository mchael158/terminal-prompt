mod paint;
mod palette;
mod sync;

use std::env;
use std::io::{self, IsTerminal, Read, Write};
use std::path::PathBuf;
use std::process::{Command, Stdio};

fn main() {
    let code = match run() {
        Ok(code) => code,
        Err(err) => {
            eprintln!("vanta: {err}");
            1
        }
    };
    std::process::exit(code);
}

fn run() -> io::Result<i32> {
    let mut args = env::args().skip(1);
    match args.next().as_deref() {
        Some("cargo") => run_cargo(args.collect()),
        Some("sync") => {
            let root = args.next().map(PathBuf::from).unwrap_or(env::current_dir()?);
            sync::write_terminal_files(&root)?;
            println!("cores gravadas a partir da paleta");
            Ok(0)
        }
        Some("install") => install(),
        _ => {
            println!(
                "vanta cargo [args]   pinta Compiling, Finished e Running\n\
                 vanta install        copia o programa para ~/.local/bin\n\
                 vanta sync [pasta]   grava kitty, alacritty, foot e o fragmento do Windows"
            );
            Ok(0)
        }
    }
}

fn run_cargo(args: Vec<String>) -> io::Result<i32> {
    if !io::stdout().is_terminal() || !io::stderr().is_terminal() {
        return status(Command::new(cargo_bin()).args(&args).status()?);
    }

    let mut child = Command::new(cargo_bin())
        .args(&args)
        .env("CARGO_TERM_COLOR", "never")
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::piped())
        .spawn()?;

    let stderr = child
        .stderr
        .take()
        .ok_or_else(|| io::Error::other("stderr do cargo nao foi canalizado"))?;
    let mut err = io::stderr().lock();
    forward_stderr(stderr, &mut err)?;
    status(child.wait()?)
}

fn forward_stderr(mut src: impl Read, out: &mut impl Write) -> io::Result<()> {
    let mut chunk = [0u8; 8192];
    let mut line = Vec::new();
    let mut held_return = false;
    loop {
        let read = src.read(&mut chunk)?;
        if read == 0 {
            if held_return {
                out.write_all(&line)?;
                out.write_all(b"\r")?;
            } else {
                write_line(out, &line)?;
            }
            break;
        }
        for &byte in &chunk[..read] {
            if held_return && byte != b'\n' {
                out.write_all(&line)?;
                out.write_all(b"\r")?;
                line.clear();
            }
            match byte {
                b'\r' => held_return = true,
                b'\n' => {
                    held_return = false;
                    write_line(out, &line)?;
                    out.write_all(b"\n")?;
                    line.clear();
                }
                _ => {
                    held_return = false;
                    line.push(byte);
                }
            }
        }
    }
    out.flush()
}

fn write_line(out: &mut impl Write, raw: &[u8]) -> io::Result<()> {
    if raw.is_empty() {
        return Ok(());
    }
    let text = String::from_utf8_lossy(raw);
    if let Some(painted) = paint::style_line(&text) {
        out.write_all(painted.as_bytes())
    } else {
        out.write_all(raw)
    }
}

fn cargo_bin() -> String {
    if cfg!(windows) { "cargo.exe".into() } else { "cargo".into() }
}

fn status(status: std::process::ExitStatus) -> io::Result<i32> {
    Ok(status.code().unwrap_or(1))
}

fn install() -> io::Result<i32> {
    let exe = env::current_exe()?;
    let home = env::var_os("USERPROFILE")
        .or_else(|| env::var_os("HOME"))
        .ok_or_else(|| io::Error::new(io::ErrorKind::NotFound, "home nao encontrado"))?;
    let dir = PathBuf::from(home).join(".local").join("bin");
    fs_create(&dir)?;
    let name = if cfg!(windows) { "vanta.exe" } else { "vanta" };
    let dest = dir.join(name);
    if exe != dest {
        std::fs::copy(&exe, &dest)?;
    }
    println!("vanta instalado em {}", dest.display());
    Ok(0)
}

fn fs_create(dir: &std::path::Path) -> io::Result<()> {
    std::fs::create_dir_all(dir)
}
