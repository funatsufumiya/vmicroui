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

	app.mu = microui.mu_new_context()
	microui.mu_init(app.mu)

	app.gg = gg.new_context(
		bg_color:      gg.Color{r: 50, g: 50, b: 50, a: 255}
		width:         win_width
		height:        win_height
		create_window: true
		window_title:  'microui HelloWorld'
		frame_fn:      frame
		click_fn:	   microui.gg_r_on_mouse_down_fn(app.mu)
		unclick_fn:	   microui.gg_r_on_mouse_up_fn(app.mu)
		move_fn:	   microui.gg_r_on_mouse_move_fn(app.mu)
		keyup_fn:	   microui.gg_r_on_key_up_fn(app.mu)
		keydown_fn:	   microui.gg_r_on_key_down_fn(app.mu)
		scroll_fn:	   microui.gg_r_on_mouse_scroll_fn(app.mu)
		user_data:     app
	)

	app.mu.text_width = microui.gg_r_text_width_fn(app.gg)
	app.mu.text_height = microui.gg_r_text_height_fn(app.gg)

	app.gg.run()
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
		microui.mu_label(ctx, c'Hello, microui!')

		if microui.mu_button(ctx, c'Click Me') != 0 {
			println('Button was pressed!')
		}

		microui.mu_label(ctx, c'Slider:')
		microui.mu_slider(ctx, &app.slider_val, 0, 100)

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