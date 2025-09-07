module microui_renderer

import gg
import microui

pub fn r_draw_text(ctx &gg.Context, text string, pos microui.Mu_Vec2, color microui.Mu_Color) {
    ctx.draw_text(pos.x, pos.y, text,
        size:  30
        color: gg.Color{r: color.r, g: color.g, b: color.b, a: color.a}
    )
}

pub fn r_draw_rect(ctx &gg.Context, rect microui.Mu_Rect, color microui.Mu_Color) {
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn r_draw_icon(ctx &gg.Context, id int, rect microui.Mu_Rect, color microui.Mu_Color) {
    // workaround
    ctx.draw_rect_filled(rect.x, rect.y, rect.w, rect.h, gg.Color{r: color.r, g: color.g, b: color.b, a: color.a})
}

pub fn r_set_clip_rect(ctx &gg.Context, rect microui.Mu_Rect) {
    // ctx.set_clip_rect(rect.x, rect.y, rect.w, rect.h)
    // currently do nothing
}