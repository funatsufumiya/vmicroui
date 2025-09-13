module main

import gg
import microui

const win_width = 400
const win_height = 300

struct App {
mut:
	gg    &gg.Context = unsafe { nil }
	mu    &C.mu_Context = unsafe { nil }
	cmd    &C.mu_Command = unsafe { nil }
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
		user_data:     app
	)

	app.mu = microui.mu_new_context()
	microui.mu_init(app.mu)
	app.mu.text_width = microui.gg_r_text_width
	app.mu.text_height = microui.gg_r_text_height
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
		// microui.mu_layout_row(ctx, 1, [280], 0)
		// microui.mu_label(ctx, c'Hello, microui!')
		microui.mu_end_window(ctx)
	}
	microui.mu_end(ctx)

	for microui.mu_next_command(ctx, &app.cmd) {
		cmd := app.cmd
		// println(microui.mu_command_type(cmd))
		unsafe {
			match microui.mu_command_type(cmd) {
				microui.mu_command_text { 
					microui.gg_r_draw_text(app.gg, microui.mu_cmd_str(cmd.text.str), cmd.text.pos, cmd.text.color)
					// println("text")
				}
				microui.mu_command_rect {
					microui.gg_r_draw_rect(app.gg, cmd.rect.rect, cmd.rect.color)
					// println("rect")
				}
				// microui.mu_command_icon {
				// 	microui.gg_r_draw_icon(app.gg, cmd.icon.id, cmd.icon.rect, cmd.icon.color)
				// }
				else {}
			}
		}
        // case MU_COMMAND_TEXT: r_draw_text(cmd->text.str, cmd->text.pos, cmd->text.color); break;
        // case MU_COMMAND_RECT: r_draw_rect(cmd->rect.rect, cmd->rect.color); break;
        // case MU_COMMAND_ICON: r_draw_icon(cmd->icon.id, cmd->icon.rect, cmd->icon.color); break;
        // case MU_COMMAND_CLIP: r_set_clip_rect(cmd->clip.rect); break;
	}
}