module main

import gg
import microui

const win_width = 400
const win_height = 300

struct App {
mut:
	gg    &gg.Context = unsafe { nil }
	mu    &microui.Mu_Context = unsafe { nil }
}

fn main() {
	mut app := &App{}
	app.gg = gg.new_context(
		bg_color:      gg.Color{r: 240, g: 240, b: 240, a: 255}
		width:         win_width
		height:        win_height
		create_window: true
		window_title:  'microui HelloWorld'
		frame_fn:      frame
		user_data:     app
	)
	ctx := microui.new_context()
	microui.mu_init(ctx)
	app.mu = ctx
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
	if microui.mu_begin_window(ctx, 'Hello', microui.Mu_Rect{50, 50, 300, 100}) {
		microui.mu_layout_row(ctx, 1, [280], 0)
		microui.mu_label(ctx, 'Hello, microui!')
		microui.mu_end_window(ctx)
	}
	microui.mu_end(ctx)

	mut cmd := microui.Mu_Command{}
	for microui.mu_next_command(ctx, cmd) {
		unsafe {
			match microui.mu_command_type(cmd) {
				microui.mu_command_text { microui.gg_r_draw_text(app.gg, microui.mu_cmd_str(cmd.text.str), cmd.text.pos, cmd.text.color) }
				microui.mu_command_rect { microui.gg_r_draw_rect(app.gg, cmd.rect.rect, cmd.rect.color) }
				// microui.mu_command_icon { microui.gg_r_draw_icon(app.gg, cmd.icon.id, cmd.icon.rect, cmd.icon.color) }
				else {}
			}
		}
        // case MU_COMMAND_TEXT: r_draw_text(cmd->text.str, cmd->text.pos, cmd->text.color); break;
        // case MU_COMMAND_RECT: r_draw_rect(cmd->rect.rect, cmd->rect.color); break;
        // case MU_COMMAND_ICON: r_draw_icon(cmd->icon.id, cmd->icon.rect, cmd->icon.color); break;
        // case MU_COMMAND_CLIP: r_set_clip_rect(cmd->clip.rect); break;
	}
}