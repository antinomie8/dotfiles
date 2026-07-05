use std::env;
use std::num::NonZeroU32;
use std::os::unix::process::CommandExt;
use std::process::{Command, Stdio};
use std::rc::Rc;

use winit::dpi::PhysicalSize;
use winit::event::{ElementState, Event, WindowEvent};
use winit::event_loop::{ControlFlow, EventLoop};
use winit::window::{Fullscreen, WindowBuilder};

fn is_inhibited() -> bool {
	env::var("IDLE_INHIBITED").is_ok()
}

fn reexec_with_inhibit() -> ! {
	let exe = env::current_exe().expect("failed to resolve current executable path");

	let err = Command::new("systemd-inhibit")
		.args([
			"--what=idle",
			"--mode=block",
			"--who=blackscreen",
			"--why=Fullscreen black screen",
		])
		.arg(exe)
		.env("IDLE_INHIBITED", "1")
		.exec();

	eprintln!("execlp(systemd-inhibit): {err}");
	std::process::exit(1);
}

/// Runs a shell command, printing `fail_msg` on non-zero exit or spawn failure
fn run_cmd(cmd: &str, args: &[&str], fail_msg: &str) {
	match Command::new(cmd).stdout(Stdio::null()).args(args).status() {
		Ok(status) if status.success() => {}
		_ => eprintln!("{fail_msg}"),
	}
}

/// Restores keyboard brightness / safeeyes and exits
fn restore_and_exit() -> ! {
	run_cmd(
		"brightnessctl",
		&["-rd", "asus::kbd_backlight"],
		"Failed to restore keyboard brightness",
	);
	run_cmd("safeeyes", &["-e"], "Failed to reenable safeeyes");
	std::process::exit(0);
}

fn main() {
	if !is_inhibited() {
		reexec_with_inhibit();
	}

	run_cmd(
		"brightnessctl",
		&["-sd", "asus::kbd_backlight", "set", "0"],
		"Failed to disable keyboard brightness",
	);
	run_cmd("safeeyes", &["-d"], "Failed to disable safeeyes");

	let event_loop = EventLoop::new().expect("failed to create event loop");

	let window = WindowBuilder::new()
		.with_title("Black Screen")
		.with_decorations(false)
		.with_fullscreen(Some(Fullscreen::Borderless(None)))
		.build(&event_loop)
		.expect("failed to create window");
	let window = Rc::new(window);

	let context = softbuffer::Context::new(window.clone()).expect("failed to create gfx context");
	let mut surface =
		softbuffer::Surface::new(&context, window.clone()).expect("failed to create surface");

	draw_black(&mut surface, window.inner_size());
	window.request_redraw();

	event_loop
		.run(move |event, elwt| {
			elwt.set_control_flow(ControlFlow::Wait);

			if let Event::WindowEvent { event, .. } = event {
				match event {
					WindowEvent::CloseRequested => restore_and_exit(),
					WindowEvent::KeyboardInput { event, .. } => {
						if event.state == ElementState::Pressed {
							restore_and_exit();
						}
					}
					WindowEvent::Resized(size) => draw_black(&mut surface, size),
					WindowEvent::RedrawRequested => {
						draw_black(&mut surface, window.inner_size());
					}
					_ => {}
				}
			}
		})
		.expect("event loop error");
}

/// Fills the entire surface with black and presents it.
fn draw_black(
	surface: &mut softbuffer::Surface<Rc<winit::window::Window>, Rc<winit::window::Window>>,
	size: PhysicalSize<u32>,
) {
	let (Some(w), Some(h)) = (NonZeroU32::new(size.width), NonZeroU32::new(size.height)) else {
		return;
	};
	if surface.resize(w, h).is_err() {
		return;
	}
	if let Ok(mut buffer) = surface.buffer_mut() {
		buffer.fill(0); // 0x00000000 == black
		let _ = buffer.present();
	}
}
