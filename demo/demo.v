module main

import gg
import microui
import microui_renderer

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
	app.mu = microui.new_context()
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
	if microui.mu_begin_window_ex(ctx, 'Hello', microui.rect(50, 50, 300, 100), 0) {
		microui.mu_layout_row(ctx, 1, [280], 0)
		microui.mu_label(ctx, 'Hello, microui!')
		microui.mu_end_window(ctx)
	}
	microui.mu_end(ctx)

	mut cmd := microui.Mu_Command{}
	for microui.next_command(ctx, mut cmd) {
		match cmd.typ {
			.text { microui_renderer.r_draw_text(app.gg, cmd.text.str, cmd.text.pos, cmd.text.color) }
			.rect { microui_renderer.r_draw_rect(app.gg, cmd.rect.rect, cmd.rect.color) }
			.icon { microui_renderer.r_draw_icon(app.gg, cmd.icon.id, cmd.icon.rect, cmd.icon.color) }
			else {}
		}
	}
}