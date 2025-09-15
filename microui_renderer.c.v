module microui

import gg

pub fn gg_r_draw_text(ctx &gg.Context, text &char, pos C.mu_Vec2, color C.mu_Color) {
    str := unsafe { cstring_to_vstring(text) }
	// println("draw_text text: ${str}")
	// println("draw_text text: ${text}, pos: ${pos}, color: ${color}")
    ctx.draw_text(pos.x, pos.y, str,
        // size:  30
        color: gg.Color{r: color.r, g: color.g, b: color.b, a: color.a}
    )
}

pub fn gg_r_draw_rect(ctx &gg.Context, rect C.mu_Rect, color C.mu_Color) {
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn gg_r_draw_icon(ctx &gg.Context, id int, rect C.mu_Rect, color C.mu_Color) {
    // workaround
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn gg_r_set_clip_rect(ctx &gg.Context, rect C.mu_Rect) {
    // ctx.set_clip_rect(rect.x, rect.y, rect.w, rect.h)
    // currently do nothing
}

pub fn gg_r_text_width_fn(ctx &gg.Context) fn(font C.mu_Font, text &char, len int) int {
    text_width_fn := ctx.text_width
    callback := fn [text_width_fn] (font C.mu_Font, text_ &char, len int) int {
       str := unsafe { cstring_to_vstring(text_) } 
       return int(text_width_fn(str))
    }
    return callback
}

pub fn gg_r_text_height_fn(ctx &gg.Context) fn(font C.mu_Font) int {
    text_height_fn := ctx.text_height
    callback := fn [text_height_fn] (font C.mu_Font) int {
    //    str := unsafe { cstring_to_vstring(text) } 
       return int(text_height_fn('H'))
    }
    return callback
}

pub fn mu_mouse_btn(btn gg.MouseButton) int {
	mut r := 0
	match btn {
		.left { r = microui.mu_mouse_left }
		.right { r = microui.mu_mouse_right }
		.middle { r = microui.mu_mouse_middle }
		else {}
	}
	return r
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

// fn mu_key(btn gg.KeyCode) int {
// 	mut r := 0
// 	match btn {
// 		.left { r = microui.mu_mouse_left }
// 		.right { r = microui.mu_mouse_right }
// 		.middle { r = microui.mu_mouse_middle }
// 		else {}
// 	}
// 	return int(r)
// }

pub fn gg_r_on_mouse_move_fn(_ctx &C.mu_Context) fn(x f32, y f32, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (x f32, y f32, ptr voidptr){
        microui.mu_input_mousemove(ctx, int(x), int(y))
    }
    return callback
}

pub fn gg_r_on_mouse_down_fn(_ctx &C.mu_Context) fn(x f32, y f32, btn gg.MouseButton, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (x f32, y f32, btn gg.MouseButton, ptr voidptr){
	    microui.mu_input_mousedown(ctx, int(x), int(y), mu_mouse_btn(btn))
    }
    return callback
}

pub fn gg_r_on_mouse_up_fn(_ctx &C.mu_Context) fn(x f32, y f32, btn gg.MouseButton, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (x f32, y f32, btn gg.MouseButton, ptr voidptr){
        microui.mu_input_mouseup(ctx, int(x), int(y), mu_mouse_btn(btn))
    }
    return callback
}

pub fn gg_r_on_mouse_scroll_fn(_ctx &C.mu_Context) fn(ev &gg.Event, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (ev &gg.Event, ptr voidptr){
        microui.mu_input_scroll(ctx, int(ev.mouse_dx), int(ev.mouse_dy))
    }
    return callback
}

pub fn gg_r_on_key_down_fn(_ctx &C.mu_Context) fn(key gg.KeyCode, modifier gg.Modifier, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (key gg.KeyCode, modifier gg.Modifier, ptr voidptr){
        microui.mu_input_keydown(ctx, int(key))
    }
    return callback
}

pub fn gg_r_on_key_up_fn(_ctx &C.mu_Context) fn(key gg.KeyCode, modifier gg.Modifier, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (key gg.KeyCode, modifier gg.Modifier, ptr voidptr){
        microui.mu_input_keyup(ctx, int(key))
    }
    return callback
}

pub fn gg_r_on_text_input_fn(_ctx &C.mu_Context) fn(text string, ptr voidptr) {
    ctx := unsafe { _ctx }
    callback := fn [ctx] (text string, ptr voidptr){
        microui.mu_input_text(ctx, text.str)
    }
    return callback
}

pub fn gg_r_render(ctx &C.mu_Context, gg_ctx &gg.Context) {
    cmd := unsafe { &C.mu_Command(nil) }

    for microui.mu_next_command(ctx, &cmd) {
		// println(microui.mu_command_type(cmd))
		unsafe {
			match microui.mu_command_type(cmd) {
				microui.mu_command_text { 
					microui.gg_r_draw_text(gg_ctx, &char(cmd.text.str), cmd.text.pos, cmd.text.color)
				}
				microui.mu_command_rect {
					microui.gg_r_draw_rect(gg_ctx, cmd.rect.rect, cmd.rect.color)
					// println("draw_rect rect: ${cmd.rect.rect}, color: ${cmd.rect.color}")
				}
				microui.mu_command_icon {
					// microui.gg_r_draw_icon(gg_ctx, cmd.icon.id, cmd.icon.rect, cmd.icon.color)
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