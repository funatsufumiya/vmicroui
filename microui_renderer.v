module microui

import gg

pub fn gg_r_draw_text(ctx &gg.Context, text string, pos microui.Mu_Vec2, color microui.Mu_Color) {
    ctx.draw_text(pos.x, pos.y, text,
        size:  30
        color: gg.Color{r: color.r, g: color.g, b: color.b, a: color.a}
    )
}

pub fn gg_r_draw_rect(ctx &gg.Context, rect microui.Mu_Rect, color microui.Mu_Color) {
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn gg_r_draw_icon(ctx &gg.Context, id int, rect microui.Mu_Rect, color microui.Mu_Color) {
    // workaround
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn gg_r_set_clip_rect(ctx &gg.Context, rect microui.Mu_Rect) {
    // ctx.set_clip_rect(rect.x, rect.y, rect.w, rect.h)
    // currently do nothing
}

pub fn gg_r_text_width(font microui.Mu_Font, text &char, len int) int {
  len_ := if len == -1 {
        unsafe { C.strlen(text) }
    }else {
        len
    }
  return unsafe { C.strlen(text) } // WORKAROUND
//   return r_get_text_width(text, len);
}

pub fn gg_r_text_height(font microui.Mu_Font) int {
//   return r_get_text_height();
    return 30 // WORKAROUND
}