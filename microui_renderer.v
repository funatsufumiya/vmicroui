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