mod paint;
mod palette;
mod sync;

use std::env;
use std::io::{self, BufRead, IsTerminal, Write};
use std::path::PathBuf;
use std::process::{Command, Stdio};

use paint::paint_line;

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
        .env("CARGO_TERM_PROGRESS_WHEN", "never")
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::piped())
        .spawn()?;

    let stderr = child.stderr.take().expect("stderr canalizado");
    let mut err = io::stderr().lock();
    for line in io::BufReader::new(stderr).lines() {
        writeln!(err, "{}", paint_line(&line?))?;
    }
    status(child.wait()?)
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
