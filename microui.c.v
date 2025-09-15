module microui

#flag -I @VMODROOT/c/microui
#flag -I @VMODROOT/c

#include "microui.h"
#include "microui.c"

//
//* Copyright (c) 2024 rxi
//*
//* This library is free software; you can redistribute it and/or modify it
//* under the terms of the MIT license. See `microui.c` for details.
//

// empty enum
pub const mu_clip_part = 1
pub const mu_clip_all = 2

// empty enum
pub const mu_command_jump = 1
pub const mu_command_clip = 2
pub const mu_command_rect = 3
pub const mu_command_text = 4
pub const mu_command_icon = 5
pub const mu_command_max = 6

// empty enum
pub const mu_color_text = 0
pub const mu_color_border = 1
pub const mu_color_windowbg = 2
pub const mu_color_titlebg = 3
pub const mu_color_titletext = 4
pub const mu_color_panelbg = 5
pub const mu_color_button = 6
pub const mu_color_buttonhover = 7
pub const mu_color_buttonfocus = 8
pub const mu_color_base = 9
pub const mu_color_basehover = 10
pub const mu_color_basefocus = 11
pub const mu_color_scrollbase = 12
pub const mu_color_scrollthumb = 13
pub const mu_color_max = 14

// empty enum
pub const mu_icon_close = 1
pub const mu_icon_check = 2
pub const mu_icon_collapsed = 3
pub const mu_icon_expanded = 4
pub const mu_icon_max = 5

// empty enum
pub const mu_res_active = 1 << 0
pub const mu_res_submit = 1 << 1
pub const mu_res_change = 1 << 2

// empty enum
pub const mu_opt_aligncenter = 1 << 0
pub const mu_opt_alignright = 1 << 1
pub const mu_opt_nointeract = 1 << 2
pub const mu_opt_noframe = 1 << 3
pub const mu_opt_noresize = 1 << 4
pub const mu_opt_noscroll = 1 << 5
pub const mu_opt_noclose = 1 << 6
pub const mu_opt_notitle = 1 << 7
pub const mu_opt_holdfocus = 1 << 8
pub const mu_opt_autosize = 1 << 9
pub const mu_opt_popup = 1 << 10
pub const mu_opt_closed = 1 << 11
pub const mu_opt_expanded = 1 << 12

// empty enum
pub const mu_mouse_left = 1 << 0
pub const mu_mouse_right = 1 << 1
pub const mu_mouse_middle = 1 << 2

// empty enum
pub const mu_key_shift = 1 << 0
pub const mu_key_ctrl = 1 << 1
pub const mu_key_alt = 1 << 2
pub const mu_key_backspace = 1 << 3
pub const mu_key_return = 1 << 4

pub type C.mu_Id = u32
pub type C.mu_Real = f32
pub type C.mu_Font = voidptr

@[typedef]
pub struct C.mu_Vec2 {
pub mut:
	x int
	y int
}

@[typedef]
pub struct C.mu_Rect {
pub mut:
	x int
	y int
	w int
	h int
}

@[typedef]
pub struct C.mu_Color {
pub mut:
	r u8
	g u8
	b u8
	a u8
}

@[typedef]
pub struct C.mu_PoolItem {
pub mut:
	id          C.mu_Id
	last_update int
}

@[typedef]
pub struct C.mu_BaseCommand {
pub mut:
	@type int
	size  int
}

@[typedef]
pub struct C.mu_JumpCommand {
pub mut:
	base C.mu_BaseCommand
	dst  voidptr
}

@[typedef]
pub struct C.mu_ClipCommand {
pub mut:
	base C.mu_BaseCommand
	rect C.mu_Rect
}

@[typedef]
pub struct C.mu_RectCommand {
pub mut:
	base  C.mu_BaseCommand
	rect  C.mu_Rect
	color C.mu_Color
}

@[typedef]
pub struct C.mu_TextCommand {
pub mut:
	base  C.mu_BaseCommand
	font  C.mu_Font
	pos   C.mu_Vec2
	color C.mu_Color
	str   [1]i8
}

@[typedef]
pub struct C.mu_IconCommand {
pub mut:
	base  C.mu_BaseCommand
	rect  C.mu_Rect
	id    int
	color C.mu_Color
}

@[typedef]
pub union C.mu_Command {
pub mut:
	@type int
	base  C.mu_BaseCommand
	jump  C.mu_JumpCommand
	clip  C.mu_ClipCommand
	rect  C.mu_RectCommand
	text  C.mu_TextCommand
	icon  C.mu_IconCommand
}

@[typedef]
pub struct C.mu_Layout {
pub mut:
	body       C.mu_Rect
	next       C.mu_Rect
	position   C.mu_Vec2
	size       C.mu_Vec2
	max        C.mu_Vec2
	widths     [16]int
	items      int
	item_index int
	next_row   int
	next_type  int
	indent     int
}

@[typedef]
pub struct C.mu_Container {
pub mut:
	head         &C.mu_Command
	tail         &C.mu_Command
	rect         C.mu_Rect
	body         C.mu_Rect
	content_size C.mu_Vec2
	scroll       C.mu_Vec2
	zindex       int
	open         int
}

@[typedef]
pub struct C.mu_Style {
pub mut:
	font           C.mu_Font
	size           C.mu_Vec2
	padding        int
	spacing        int
	indent         int
	title_height   int
	scrollbar_size int
	thumb_size     int
	colors         [14]C.mu_Color
}

@[typedef]
pub struct C.mu_Context {
pub mut:
	// callbacks
	text_width  fn (C.mu_Font, &char, int) int
	text_height fn (C.mu_Font) int
	draw_frame  fn (&C.mu_Context, C.mu_Rect, int)
	// core state
	_style          C.mu_Style
	style           &C.mu_Style
	hover           C.mu_Id
	focus           C.mu_Id
	last_id         C.mu_Id
	last_rect       C.mu_Rect
	last_zindex     int
	updated_focus   int
	frame           int
	hover_root      &C.mu_Container
	next_hover_root &C.mu_Container
	scroll_target   &C.mu_Container
	number_edit_buf [127]i8
	number_edit     C.mu_Id
	// stacks
	command_list struct {
		idx   int
		items [262144]i8
	}

	root_list struct {
		idx   int
		items [32]&C.mu_Container
	}

	container_stack struct {
		idx   int
		items [32]&C.mu_Container
	}

	clip_stack struct {
		idx   int
		items [32]C.mu_Rect
	}

	id_stack struct {
		idx   int
		items [32]C.mu_Id
	}

	layout_stack struct {
		idx   int
		items [16]C.mu_Layout
	}

	// retained state pools
	container_pool [48]C.mu_PoolItem
	containers     [48]C.mu_Container
	treenode_pool  [48]C.mu_PoolItem
	// input state
	mouse_pos      C.mu_Vec2
	last_mouse_pos C.mu_Vec2
	mouse_delta    C.mu_Vec2
	scroll_delta   C.mu_Vec2
	mouse_down     int
	mouse_pressed  int
	key_down       int
	key_pressed    int
	input_text     [32]i8
}

fn C.mu_vec2(x int, y int) C.mu_Vec2

pub fn mu_vec2(x int, y int) C.mu_Vec2 {
	return C.mu_vec2(x, y)
}

fn C.mu_rect(x int, y int, w int, h int) C.mu_Rect

pub fn mu_rect(x int, y int, w int, h int) C.mu_Rect {
	return C.mu_rect(x, y, w, h)
}

fn C.mu_color(r int, g int, b int, a int) C.mu_Color

pub fn mu_color(r int, g int, b int, a int) C.mu_Color {
	return C.mu_color(r, g, b, a)
}

fn C.mu_init(ctx &C.mu_Context)

pub fn mu_init(ctx &C.mu_Context) {
	C.mu_init(ctx)
}

fn C.mu_begin(ctx &C.mu_Context)

pub fn mu_begin(ctx &C.mu_Context) {
	C.mu_begin(ctx)
}

fn C.mu_end(ctx &C.mu_Context)

pub fn mu_end(ctx &C.mu_Context) {
	C.mu_end(ctx)
}

fn C.mu_set_focus(ctx &C.mu_Context, id C.mu_Id)

pub fn mu_set_focus(ctx &C.mu_Context, id C.mu_Id) {
	C.mu_set_focus(ctx, id)
}

fn C.mu_get_id(ctx &C.mu_Context, data voidptr, size int) C.mu_Id

pub fn mu_get_id(ctx &C.mu_Context, data voidptr, size int) C.mu_Id {
	return C.mu_get_id(ctx, data, size)
}

fn C.mu_push_id(ctx &C.mu_Context, data voidptr, size int)

pub fn mu_push_id(ctx &C.mu_Context, data voidptr, size int) {
	C.mu_push_id(ctx, data, size)
}

fn C.mu_pop_id(ctx &C.mu_Context)

pub fn mu_pop_id(ctx &C.mu_Context) {
	C.mu_pop_id(ctx)
}

fn C.mu_push_clip_rect(ctx &C.mu_Context, rect C.mu_Rect)

pub fn mu_push_clip_rect(ctx &C.mu_Context, rect C.mu_Rect) {
	C.mu_push_clip_rect(ctx, rect)
}

fn C.mu_pop_clip_rect(ctx &C.mu_Context)

pub fn mu_pop_clip_rect(ctx &C.mu_Context) {
	C.mu_pop_clip_rect(ctx)
}

fn C.mu_get_clip_rect(ctx &C.mu_Context) C.mu_Rect

pub fn mu_get_clip_rect(ctx &C.mu_Context) C.mu_Rect {
	return C.mu_get_clip_rect(ctx)
}

fn C.mu_check_clip(ctx &C.mu_Context, r C.mu_Rect) int

pub fn mu_check_clip(ctx &C.mu_Context, r C.mu_Rect) bool {
	return C.mu_check_clip(ctx, r) != 0
}

fn C.mu_get_current_container(ctx &C.mu_Context) &C.mu_Container

pub fn mu_get_current_container(ctx &C.mu_Context) &C.mu_Container {
	return C.mu_get_current_container(ctx)
}

fn C.mu_get_container(ctx &C.mu_Context, name &char) &C.mu_Container

pub fn mu_get_container(ctx &C.mu_Context, name &char) &C.mu_Container {
	return C.mu_get_container(ctx, name)
}

fn C.mu_bring_to_front(ctx &C.mu_Context, cnt &C.mu_Container)

pub fn mu_bring_to_front(ctx &C.mu_Context, cnt &C.mu_Container) {
	C.mu_bring_to_front(ctx, cnt)
}

fn C.mu_pool_init(ctx &C.mu_Context, items &C.mu_PoolItem, len int, id C.mu_Id) int

pub fn mu_pool_init(ctx &C.mu_Context, items &C.mu_PoolItem, len int, id C.mu_Id) bool {
	return C.mu_pool_init(ctx, items, len, id) != 0
}

fn C.mu_pool_get(ctx &C.mu_Context, items &C.mu_PoolItem, len int, id C.mu_Id) int

pub fn mu_pool_get(ctx &C.mu_Context, items &C.mu_PoolItem, len int, id C.mu_Id) bool {
	return C.mu_pool_get(ctx, items, len, id) != 0
}

fn C.mu_pool_update(ctx &C.mu_Context, items &C.mu_PoolItem, idx int)

pub fn mu_pool_update(ctx &C.mu_Context, items &C.mu_PoolItem, idx int) {
	C.mu_pool_update(ctx, items, idx)
}

fn C.mu_input_mousemove(ctx &C.mu_Context, x int, y int)

pub fn mu_input_mousemove(ctx &C.mu_Context, x int, y int) {
	C.mu_input_mousemove(ctx, x, y)
}

fn C.mu_input_mousedown(ctx &C.mu_Context, x int, y int, btn int)

pub fn mu_input_mousedown(ctx &C.mu_Context, x int, y int, btn int) {
	C.mu_input_mousedown(ctx, x, y, btn)
}

fn C.mu_input_mouseup(ctx &C.mu_Context, x int, y int, btn int)

pub fn mu_input_mouseup(ctx &C.mu_Context, x int, y int, btn int) {
	C.mu_input_mouseup(ctx, x, y, btn)
}

fn C.mu_input_scroll(ctx &C.mu_Context, x int, y int)

pub fn mu_input_scroll(ctx &C.mu_Context, x int, y int) {
	C.mu_input_scroll(ctx, x, y)
}

fn C.mu_input_keydown(ctx &C.mu_Context, key int)

pub fn mu_input_keydown(ctx &C.mu_Context, key int) {
	C.mu_input_keydown(ctx, key)
}

fn C.mu_input_keyup(ctx &C.mu_Context, key int)

pub fn mu_input_keyup(ctx &C.mu_Context, key int) {
	C.mu_input_keyup(ctx, key)
}

fn C.mu_input_text(ctx &C.mu_Context, text &char)

pub fn mu_input_text(ctx &C.mu_Context, text &char) {
	C.mu_input_text(ctx, text)
}

fn C.mu_push_command(ctx &C.mu_Context, type_ int, size int) &C.mu_Command

pub fn mu_push_command(ctx &C.mu_Context, type_ int, size int) &C.mu_Command {
	return C.mu_push_command(ctx, type_, size)
}

fn C.mu_next_command(ctx &C.mu_Context, cmd &&C.mu_Command) int

pub fn mu_next_command(ctx &C.mu_Context, cmd &&C.mu_Command) bool {
	return C.mu_next_command(ctx, cmd) != 0
}

fn C.mu_set_clip(ctx &C.mu_Context, rect C.mu_Rect)

pub fn mu_set_clip(ctx &C.mu_Context, rect C.mu_Rect) {
	C.mu_set_clip(ctx, rect)
}

fn C.mu_draw_rect(ctx &C.mu_Context, rect C.mu_Rect, color C.mu_Color)

pub fn mu_draw_rect(ctx &C.mu_Context, rect C.mu_Rect, color C.mu_Color) {
	C.mu_draw_rect(ctx, rect, color)
}

fn C.mu_draw_box(ctx &C.mu_Context, rect C.mu_Rect, color C.mu_Color)

pub fn mu_draw_box(ctx &C.mu_Context, rect C.mu_Rect, color C.mu_Color) {
	C.mu_draw_box(ctx, rect, color)
}

fn C.mu_draw_text(ctx &C.mu_Context, font C.mu_Font, str &char, len int, pos C.mu_Vec2, color C.mu_Color)

pub fn mu_draw_text(ctx &C.mu_Context, font C.mu_Font, str &char, len int, pos C.mu_Vec2, color C.mu_Color) {
	C.mu_draw_text(ctx, font, str, len, pos, color)
}

fn C.mu_draw_icon(ctx &C.mu_Context, id int, rect C.mu_Rect, color C.mu_Color)

pub fn mu_draw_icon(ctx &C.mu_Context, id int, rect C.mu_Rect, color C.mu_Color) {
	C.mu_draw_icon(ctx, id, rect, color)
}

fn C.mu_layout_row(ctx &C.mu_Context, items int, widths &int, height int)

pub fn mu_layout_row(ctx &C.mu_Context, items int, widths []int, height int) {
	C.mu_layout_row(ctx, items, widths.data, height)
}

fn C.mu_layout_width(ctx &C.mu_Context, width int)

pub fn mu_layout_width(ctx &C.mu_Context, width int) {
	C.mu_layout_width(ctx, width)
}

fn C.mu_layout_height(ctx &C.mu_Context, height int)

pub fn mu_layout_height(ctx &C.mu_Context, height int) {
	C.mu_layout_height(ctx, height)
}

fn C.mu_layout_begin_column(ctx &C.mu_Context)

pub fn mu_layout_begin_column(ctx &C.mu_Context) {
	C.mu_layout_begin_column(ctx)
}

fn C.mu_layout_end_column(ctx &C.mu_Context)

pub fn mu_layout_end_column(ctx &C.mu_Context) {
	C.mu_layout_end_column(ctx)
}

fn C.mu_layout_set_next(ctx &C.mu_Context, r C.mu_Rect, relative int)

pub fn mu_layout_set_next(ctx &C.mu_Context, r C.mu_Rect, relative int) {
	C.mu_layout_set_next(ctx, r, relative)
}

fn C.mu_layout_next(ctx &C.mu_Context) C.mu_Rect

pub fn mu_layout_next(ctx &C.mu_Context) C.mu_Rect {
	return C.mu_layout_next(ctx)
}

fn C.mu_draw_control_frame(ctx &C.mu_Context, id C.mu_Id, rect C.mu_Rect, colorid int, opt int)

pub fn mu_draw_control_frame(ctx &C.mu_Context, id C.mu_Id, rect C.mu_Rect, colorid int, opt int) {
	C.mu_draw_control_frame(ctx, id, rect, colorid, opt)
}

fn C.mu_draw_control_text(ctx &C.mu_Context, str &char, rect C.mu_Rect, colorid int, opt int)

pub fn mu_draw_control_text(ctx &C.mu_Context, str &char, rect C.mu_Rect, colorid int, opt int) {
	C.mu_draw_control_text(ctx, str, rect, colorid, opt)
}

fn C.mu_mouse_over(ctx &C.mu_Context, rect C.mu_Rect) int

pub fn mu_mouse_over(ctx &C.mu_Context, rect C.mu_Rect) bool {
	return C.mu_mouse_over(ctx, rect) != 0
}

fn C.mu_update_control(ctx &C.mu_Context, id C.mu_Id, rect C.mu_Rect, opt int)

pub fn mu_update_control(ctx &C.mu_Context, id C.mu_Id, rect C.mu_Rect, opt int) {
	C.mu_update_control(ctx, id, rect, opt)
}

fn C.mu_text(ctx &C.mu_Context, text &char)

pub fn mu_text(ctx &C.mu_Context, text &char) {
	C.mu_text(ctx, text)
}

fn C.mu_label(ctx &C.mu_Context, text &char)

pub fn mu_label(ctx &C.mu_Context, text &char) {
	C.mu_label(ctx, text)
}

fn C.mu_button_ex(ctx &C.mu_Context, label &char, icon int, opt int) int

pub fn mu_button_ex(ctx &C.mu_Context, label &char, icon int, opt int) bool {
	return C.mu_button_ex(ctx, label, icon, opt) != 0
}

fn C.mu_checkbox(ctx &C.mu_Context, label &char, state &int) int

pub fn mu_checkbox(ctx &C.mu_Context, label &char, state &int) bool {
	return C.mu_checkbox(ctx, label, state) != 0
}

fn C.mu_textbox_raw(ctx &C.mu_Context, buf &char, bufsz int, id C.mu_Id, r C.mu_Rect, opt int) int

pub fn mu_textbox_raw(ctx &C.mu_Context, buf &char, bufsz int, id C.mu_Id, r C.mu_Rect, opt int) bool {
	return C.mu_textbox_raw(ctx, buf, bufsz, id, r, opt) != 0
}

fn C.mu_textbox_ex(ctx &C.mu_Context, buf &char, bufsz int, opt int) int

pub fn mu_textbox_ex(ctx &C.mu_Context, buf &char, bufsz int, opt int) bool {
	return C.mu_textbox_ex(ctx, buf, bufsz, opt) != 0
}

fn C.mu_slider_ex(ctx &C.mu_Context, value &C.mu_Real, low C.mu_Real, high C.mu_Real, step C.mu_Real, fmt &char, opt int) int

pub fn mu_slider_ex(ctx &C.mu_Context, value &f32, low f32, high f32, step f32, fmt &char, opt int) bool {
	return C.mu_slider_ex(ctx, value, low, high, step, fmt, opt) != 0
}

fn C.mu_number_ex(ctx &C.mu_Context, value &C.mu_Real, step C.mu_Real, fmt &char, opt int) int

pub fn mu_number_ex(ctx &C.mu_Context, value &f32, step f32, fmt &char, opt int) bool {
	return C.mu_number_ex(ctx, value, step, fmt, opt) != 0
}

fn C.mu_header_ex(ctx &C.mu_Context, label &char, opt int) int

pub fn mu_header_ex(ctx &C.mu_Context, label &char, opt int) bool {
	return C.mu_header_ex(ctx, label, opt) != 0
}

fn C.mu_begin_treenode_ex(ctx &C.mu_Context, label &char, opt int) int

pub fn mu_begin_treenode_ex(ctx &C.mu_Context, label &char, opt int) bool {
	return C.mu_begin_treenode_ex(ctx, label, opt) != 0
}

fn C.mu_end_treenode(ctx &C.mu_Context)

pub fn mu_end_treenode(ctx &C.mu_Context) {
	C.mu_end_treenode(ctx)
}

fn C.mu_begin_window_ex(ctx &C.mu_Context, title &char, rect C.mu_Rect, opt int) int

pub fn mu_begin_window_ex(ctx &C.mu_Context, title &char, rect C.mu_Rect, opt int) bool {
	return C.mu_begin_window_ex(ctx, title, rect, opt) != 0
}

fn C.mu_end_window(ctx &C.mu_Context)

pub fn mu_end_window(ctx &C.mu_Context) {
	C.mu_end_window(ctx)
}

fn C.mu_open_popup(ctx &C.mu_Context, name &char)

pub fn mu_open_popup(ctx &C.mu_Context, name &char) {
	C.mu_open_popup(ctx, name)
}

fn C.mu_begin_popup(ctx &C.mu_Context, name &char) int

pub fn mu_begin_popup(ctx &C.mu_Context, name &char) bool {
	return C.mu_begin_popup(ctx, name) != 0
}

fn C.mu_end_popup(ctx &C.mu_Context)

pub fn mu_end_popup(ctx &C.mu_Context) {
	C.mu_end_popup(ctx)
}

fn C.mu_begin_panel_ex(ctx &C.mu_Context, name &char, opt int)

pub fn mu_begin_panel_ex(ctx &C.mu_Context, name &char, opt int) {
	C.mu_begin_panel_ex(ctx, name, opt)
}

fn C.mu_end_panel(ctx &C.mu_Context)

pub fn mu_end_panel(ctx &C.mu_Context) {
	C.mu_end_panel(ctx)
}

// #define mu_button(ctx, label)             mu_button_ex(ctx, label, 0, MU_OPT_ALIGNCENTER)
// #define mu_textbox(ctx, buf, bufsz)       mu_textbox_ex(ctx, buf, bufsz, 0)
// #define mu_slider(ctx, value, lo, hi)     mu_slider_ex(ctx, value, lo, hi, 0, MU_SLIDER_FMT, MU_OPT_ALIGNCENTER)
// #define mu_number(ctx, value, step)       mu_number_ex(ctx, value, step, MU_SLIDER_FMT, MU_OPT_ALIGNCENTER)
// #define mu_header(ctx, label)             mu_header_ex(ctx, label, 0)
// #define mu_begin_treenode(ctx, label)     mu_begin_treenode_ex(ctx, label, 0)
// #define mu_begin_window(ctx, title, rect) mu_begin_window_ex(ctx, title, rect, 0)
// #define mu_begin_panel(ctx, name)         mu_begin_panel_ex(ctx, name, 0)

// V equivalents for the above macros
pub fn mu_button(ctx &C.mu_Context, label &char) bool {
	return mu_button_ex(ctx, label, 0, mu_opt_aligncenter)
}

pub fn mu_textbox(ctx &C.mu_Context, buf &char, bufsz int) bool {
	return mu_textbox_ex(ctx, buf, bufsz, 0)
}

pub fn mu_slider(ctx &C.mu_Context, value &f32, lo f32, hi f32) bool {
	return mu_slider_ex(ctx, value, lo, hi, 0, c'%.3g', mu_opt_aligncenter)
}

pub fn mu_number(ctx &C.mu_Context, value &f32, step f32) bool {
	return mu_number_ex(ctx, value, step, c'%.3g', mu_opt_aligncenter)
}

pub fn mu_header(ctx &C.mu_Context, label &char) bool {
	return mu_header_ex(ctx, label, 0)
}

pub fn mu_begin_treenode(ctx &C.mu_Context, label &char) bool {
	return mu_begin_treenode_ex(ctx, label, 0)
}

pub fn mu_begin_window(ctx &C.mu_Context, title &char, rect C.mu_Rect) bool {
	return mu_begin_window_ex(ctx, title, rect, 0)
}

pub fn mu_begin_panel(ctx &C.mu_Context, name &char) {
	mu_begin_panel_ex(ctx, name, 0)
}

// pub fn mu_min(a int, b int) {
// 	return (a) < (b) ? (a) : (b)
// }

// utilities

#include "microui_util.h"

pub fn C.mu_command_type (cmd &C.mu_Command) int

pub fn mu_command_type (cmd &C.mu_Command) int {
	return C.mu_command_type(cmd)
}

pub fn mu_new_context() &C.mu_Context {
	return unsafe { C.malloc(sizeof(C.mu_Context)) }
}