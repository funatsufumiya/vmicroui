module main

import gg
import microui

const win_width = 600
const win_height = 400

struct App {
mut:
	gg    &gg.Context = unsafe { nil }
	mu    &C.mu_Context = unsafe { nil }
	slider_val f32 = 1.0
}

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		bg_color:      gg.Color{r: 50, g: 50, b: 50, a: 255}
		width:         win_width
		height:        win_height
		create_window: true
		window_title:  'microui HelloWorld'
		frame_fn:      frame
		click_fn:	   on_mouse_down,
		unclick_fn:	   on_mouse_up,
		move_fn:	   on_mouse_move,
		keyup_fn:	   on_key_up,
		keydown_fn:	   on_key_down,
		scroll_fn:	   on_mouse_scroll,
		user_data:     app
	)

	app.mu = microui.mu_new_context()
	microui.mu_init(app.mu)
	app.mu.text_width = microui.gg_r_text_width_fn(app.gg)
	app.mu.text_height = microui.gg_r_text_height_fn(app.gg)
	app.gg.run()
}

fn mu_mouse_btn(btn gg.MouseButton) i32 {
	mut r := 0
	match btn {
		.left { r = microui.mu_mouse_left }
		.right { r = microui.mu_mouse_right }
		.middle { r = microui.mu_mouse_middle }
		else {}
	}
	return i32(r)
}

// static const char key_map[256] = {
//   [ SDLK_LSHIFT       & 0xff ] = MU_KEY_SHIFT,
//   [ SDLK_RSHIFT       & 0xff ] = MU_KEY_SHIFT,
//   [ SDLK_LCTRL        & 0xff ] = MU_KEY_CTRL,
//   [ SDLK_RCTRL        & 0xff ] = MU_KEY_CTRL,
//   [ SDLK_LALT         & 0xff ] = MU_KEY_ALT,
//   [ SDLK_RALT         & 0xff ] = MU_KEY_ALT,
//   [ SDLK_RETURN       & 0xff ] = MU_KEY_RETURN,
//   [ SDLK_BACKSPACE    & 0xff ] = MU_KEY_BACKSPACE,
// };

// fn mu_key(btn gg.KeyCode) i32 {
// 	mut r := 0
// 	match btn {
// 		.left { r = microui.mu_mouse_left }
// 		.right { r = microui.mu_mouse_right }
// 		.middle { r = microui.mu_mouse_middle }
// 		else {}
// 	}
// 	return i32(r)
// }

fn on_mouse_move(x f32, y f32, app &App) {
    microui.mu_input_mousemove(app.mu, i32(x), i32(y))
}

fn on_mouse_down(x f32, y f32, btn gg.MouseButton, app &App) {
	microui.mu_input_mousedown(app.mu, i32(x), i32(y), mu_mouse_btn(btn))
}

fn on_mouse_up(x f32, y f32, btn gg.MouseButton, app &App) {
    microui.mu_input_mouseup(app.mu, i32(x), i32(y), mu_mouse_btn(btn))
}

fn on_mouse_scroll(ev &gg.Event, app &App) {
    microui.mu_input_scroll(app.mu, i32(ev.mouse_dx), i32(ev.mouse_dy))
}

fn on_key_down(key gg.KeyCode, modifier gg.Modifier, app &App) {
    microui.mu_input_keydown(app.mu, i32(key))
}

fn on_key_up(key gg.KeyCode, modifier gg.Modifier, app &App) {
    microui.mu_input_keyup(app.mu, i32(key))
}

fn on_text_input(text string, app &App) {
    microui.mu_input_text(app.mu, text.str)
}

fn frame(app &App) {
	app.gg.begin()
	process_frame(app)
	app.gg.end()
}

fn process_frame(app &App) {
	mut ctx := app.mu
	microui.mu_begin(ctx)
	rect := C.mu_Rect{50, 50, 300, 100}
	if microui.mu_begin_window(ctx, c'Hello', rect) {
		microui.mu_layout_row(ctx, 1, [i32(280)], 0)
		microui.mu_label(ctx, c'Hello, microui!')
		microui.mu_layout_row(ctx, 2, [i32(80), i32(-1)], 0)

		if microui.mu_button(ctx, c'Click Me') != 0 {
			println('Button was pressed!')
		}

		microui.mu_layout_row(ctx, 2, [i32(80), i32(-1)], 0)
		microui.mu_label(ctx, c'Slider:')
		microui.mu_slider(ctx, &app.slider_val, 0, 100)
		// microui.mu_label(ctx, ('Value: ${slider_val:.1f}').str)

		microui.mu_end_window(ctx)
	}
	microui.mu_end(ctx)
	
	cmd := unsafe { &C.mu_Command(nil) }

	// println("start")

	for microui.mu_next_command(ctx, &cmd) {
		// println(microui.mu_command_type(cmd))
		unsafe {
			match microui.mu_command_type(cmd) {
				microui.mu_command_text { 
					microui.gg_r_draw_text(app.gg, &char(cmd.text.str), cmd.text.pos, cmd.text.color)
				}
				microui.mu_command_rect {
					microui.gg_r_draw_rect(app.gg, cmd.rect.rect, cmd.rect.color)
					// println("draw_rect rect: ${cmd.rect.rect}, color: ${cmd.rect.color}")
				}
				microui.mu_command_icon {
					// microui.gg_r_draw_icon(app.gg, cmd.icon.id, cmd.icon.rect, cmd.icon.color)
				}
				microui.mu_command_clip {
				}
				else {}
			}
		}
        // case MU_COMMAND_TEXT: r_draw_text(cmd->text.str, cmd->text.pos, cmd->text.color); break;
        // case MU_COMMAND_RECT: r_draw_rect(cmd->rect.rect, cmd->rect.color); break;
        // case MU_COMMAND_ICON: r_draw_icon(cmd->icon.id, cmd->icon.rect, cmd->icon.color); break;
        // case MU_COMMAND_CLIP: r_set_clip_rect(cmd->clip.rect); break;
	}
}