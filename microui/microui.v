@[translated]
module microui

import strconv

//
//* Copyright (c) 2024 rxi
//*
//* This library is free software; you can redistribute it and/or modify it
//* under the terms of the MIT license. See `microui.c` for details.
//

// empty enum
pub const mu_clip_part = 1
pub const mu_clip_all = 1

// empty enum
pub const mu_command_jump = 1
pub const mu_command_clip = 1
pub const mu_command_rect = 2
pub const mu_command_text = 3
pub const mu_command_icon = 4
pub const mu_command_max = 5

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
pub const mu_icon_check = 1
pub const mu_icon_collapsed = 2
pub const mu_icon_expanded = 3
pub const mu_icon_max = 4

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

type Mu_Id = u32
type Mu_Real = f32
type Mu_Font = voidptr

pub struct Mu_Vec2 {
pub mut:
	x int
	y int
}

pub struct Mu_Rect {
pub mut:
	x int
	y int
	w int
	h int
}

pub struct Mu_Color {
pub mut:
	r u8
	g u8
	b u8
	a u8
}

pub struct Mu_PoolItem {
pub mut:
	id          Mu_Id
	last_update int
}

pub struct Mu_BaseCommand {
pub mut:
	type_ int
	size  int
}

pub struct Mu_JumpCommand {
pub mut:
	base Mu_BaseCommand
	dst  voidptr
}

pub struct Mu_ClipCommand {
pub mut:
	base Mu_BaseCommand
	rect Mu_Rect
}

pub struct Mu_RectCommand {
pub mut:
	base  Mu_BaseCommand
	rect  Mu_Rect
	color Mu_Color
}

pub struct Mu_TextCommand {
pub mut:
	base  Mu_BaseCommand
	font  Mu_Font
	pos   Mu_Vec2
	color Mu_Color
	str   [1]i8
}

pub struct Mu_IconCommand {
pub mut:
	base  Mu_BaseCommand
	rect  Mu_Rect
	id    int
	color Mu_Color
}

pub union Mu_Command {
pub mut:
	type_ int
	base  Mu_BaseCommand
	jump  Mu_JumpCommand
	clip  Mu_ClipCommand
	rect  Mu_RectCommand
	text  Mu_TextCommand
	icon  Mu_IconCommand
}

pub fn mu_command_type (cmd &Mu_Command) int {
	return unsafe{ cmd.type_ }
}

pub fn mu_str (str_i8 []i8) string {
	s := str_i8.map(u8(it))
	return s.str()
}

pub fn mu_cmd_str (str_i8 [1]i8) string {
	s := str_i8.map(u8(it))
	return s.str()
}

pub struct Mu_Layout {
pub mut:
	body       Mu_Rect
	next       Mu_Rect
	position   Mu_Vec2
	size       Mu_Vec2
	max        Mu_Vec2
	widths     [16]int
	items      int
	item_index int
	next_row   int
	next_type  int
	indent     bool
}

pub struct Mu_Container {
pub mut:
	head         &Mu_Command
	tail         &Mu_Command
	rect         Mu_Rect
	body         Mu_Rect
	content_size Mu_Vec2
	scroll       Mu_Vec2
	zindex       int
	open         int
}

pub struct Mu_Style {
pub mut:
	font           Mu_Font
	size           Mu_Vec2
	padding        int
	spacing        int
	indent         int
	title_height   int
	scrollbar_size int
	thumb_size     int
	colors         [14]Mu_Color
}

pub struct Mu_Context {
pub mut:
	// callbacks
	text_width  fn (Mu_Font, &i8, int) int
	text_height fn (Mu_Font) int
	draw_frame  fn (&Mu_Context, Mu_Rect, int)
	// core state
	_style          Mu_Style
	style           &Mu_Style
	hover           Mu_Id
	focus           Mu_Id
	last_id         Mu_Id
	last_rect       Mu_Rect
	last_zindex     int
	updated_focus   int
	frame           int
	hover_root      &Mu_Container
	next_hover_root &Mu_Container
	scroll_target   &Mu_Container
	number_edit_buf [127]i8
	number_edit     Mu_Id
	// stacks
	command_list struct {
		idx   int
		items [262144]i8
	}

	root_list struct {
		idx   int
		items [32]&Mu_Container
	}

	container_stack struct {
		idx   int
		items [32]&Mu_Container
	}

	clip_stack struct {
		idx   int
		items [32]Mu_Rect
	}

	id_stack struct {
		idx   int
		items [32]Mu_Id
	}

	layout_stack struct {
		idx   int
		items [16]Mu_Layout
	}

	// retained state pools
	container_pool [48]Mu_PoolItem
	containers     [48]Mu_Container
	treenode_pool  [48]Mu_PoolItem
	// input state
	mouse_pos      Mu_Vec2
	last_mouse_pos Mu_Vec2
	mouse_delta    Mu_Vec2
	scroll_delta   Mu_Vec2
	mouse_down     int
	mouse_pressed  int
	key_down       int
	key_pressed    int
	input_text     [32]i8
}

pub fn new_context() &Mu_Context {
	return C.malloc(sizeof(Mu_Context))
}

//
//* Copyright (c) 2024 rxi
//*
//* Permission is hereby granted, free of charge, to any person obtaining a copy
//* of this software and associated documentation files (the "Software"), to
//* deal in the Software without restriction, including without limitation the
//* rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//* sell copies of the Software, and to permit persons to whom the Software is
//* furnished to do so, subject to the following conditions:
//*
//* The above copyright notice and this permission notice shall be included in
//* all copies or substantial portions of the Software.
//*
//* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//* FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//* IN THE SOFTWARE.
//
// incremented after incase `val` uses this value
pub fn mu_vec2(x int, y int) Mu_Vec2 {
	res := Mu_Vec2{}
	res.x = x
	res.y = y
	return res
}

pub fn mu_rect(x int, y int, w int, h int) Mu_Rect {
	res := Mu_Rect{}
	res.x = x
	res.y = y
	res.w = w
	res.h = h
	return res
}

pub fn mu_color(r int, g int, b int, a int) Mu_Color {
	res := Mu_Color{}
	res.r = r
	res.g = g
	res.b = b
	res.a = a
	return res
}

pub fn expand_rect(rect Mu_Rect, n int) Mu_Rect {
	return mu_rect(rect.x - n, rect.y - n, rect.w + n * 2, rect.h + n * 2)
}

pub fn intersect_rects(r1 Mu_Rect, r2 Mu_Rect) Mu_Rect {
	x1 := (if (r1.x) > (r2.x) { (r1.x) } else { (r2.x) })
	y1 := (if (r1.y) > (r2.y) { (r1.y) } else { (r2.y) })
	x2 := (if (r1.x + r1.w) < (r2.x + r2.w) { (r1.x + r1.w) } else { (r2.x + r2.w) })
	y2 := (if (r1.y + r1.h) < (r2.y + r2.h) { (r1.y + r1.h) } else { (r2.y + r2.h) })
	if x2 < x1 {
		x2 = x1
	}
	if y2 < y1 {
		y2 = y1
	}
	return mu_rect(x1, y1, x2 - x1, y2 - y1)
}

pub fn rect_overlaps_vec2(r Mu_Rect, p Mu_Vec2) bool {
	return p.x >= r.x && p.x < r.x + r.w && p.y >= r.y && p.y < r.y + r.h
}

pub fn draw_frame(ctx &Mu_Context, rect Mu_Rect, colorid int) {
	mu_draw_rect(ctx, rect, ctx.style.colors[colorid])
	if colorid == mu_color_scrollbase || colorid == mu_color_scrollthumb
		|| colorid == mu_color_titlebg {
		return
	}
	// draw border
	if ctx.style.colors[int(mu_color_border)].a {
		mu_draw_box(ctx, expand_rect(rect, 1), ctx.style.colors[int(mu_color_border)])
	}
}

pub fn mu_init(ctx &Mu_Context) {
	C.memset(ctx, 0, sizeof(*ctx))
	ctx.draw_frame = draw_frame
	ctx._style = default_style
	ctx.style = &ctx._style
}

pub fn mu_begin(ctx &Mu_Context) {
	// assert (ctx.text_width && ctx.text_height);

	ctx.command_list.idx = 0
	ctx.root_list.idx = 0
	ctx.scroll_target = (unsafe { nil })
	ctx.hover_root = ctx.next_hover_root
	ctx.next_hover_root = (unsafe { nil })
	ctx.mouse_delta.x = ctx.mouse_pos.x - ctx.last_mouse_pos.x
	ctx.mouse_delta.y = ctx.mouse_pos.y - ctx.last_mouse_pos.y
	ctx.frame++
}

pub fn compare_zindex(a &&Mu_Container, b &&Mu_Container) int {
	return (*&&Mu_Container(a)).zindex - (*&&Mu_Container(b)).zindex
}

pub fn mu_end(ctx &Mu_Context) {
	i := 0
	n := 0

	// check stacks
	assert ctx.container_stack.idx == 0;
	assert ctx.clip_stack.idx == 0;
	assert ctx.id_stack.idx == 0;
	assert ctx.layout_stack.idx == 0;

	// handle scroll input
	if ctx.scroll_target {
		ctx.scroll_target.scroll.x += ctx.scroll_delta.x
		ctx.scroll_target.scroll.y += ctx.scroll_delta.y
	}
	// unset focus if focus id was not touched this frame
	if !ctx.updated_focus {
		ctx.focus = 0
	}
	ctx.updated_focus = 0
	// bring hover root to front if mouse was pressed
	if ctx.mouse_pressed && ctx.next_hover_root && ctx.next_hover_root.zindex < ctx.last_zindex
		&& ctx.next_hover_root.zindex >= 0 {
		mu_bring_to_front(ctx, ctx.next_hover_root)
	}
	// reset input state
	ctx.key_pressed = 0
	ctx.input_text[0] = `\0`
	ctx.mouse_pressed = 0
	ctx.scroll_delta = mu_vec2(0, 0)
	ctx.last_mouse_pos = ctx.mouse_pos
	// sort root containers by zindex
	n = ctx.root_list.idx
	// C.qsort(ctx.root_list.items, n, sizeof(&Mu_Container), compare_zindex)
	ctx.root_list.items[..n].sort_with_compare(compare_zindex)
	// set root container jump commands
	for i = 0; i < n; i++ {
		cnt := ctx.root_list.items[i]
		// if this is the first container then make the first command jump to it.
		//    * otherwise set the previous container's tail to jump to this one
		if i == 0 {
			cmd := &Mu_Command(&int(ctx.command_list.items))
			cmd.jump.dst = unsafe { &i8(cnt.head) + sizeof(Mu_JumpCommand) }
		} else {
			prev := ctx.root_list.items[i - 1]
			prev.tail.jump.dst = unsafe { &i8(cnt.head) + sizeof(Mu_JumpCommand) }
		}
		// make the last container's tail jump to the end of command list
		if i == n - 1 {
			cnt.tail.jump.dst = ctx.command_list.items + ctx.command_list.idx
		}
	}
}

pub fn mu_set_focus(ctx &Mu_Context, id Mu_Id) {
	ctx.focus = id
	ctx.updated_focus = 1
}

// 32bit fnv-1a hash
pub fn hash(hash &Mu_Id, data voidptr, size int) {
	// p := data
	mut p := &u8(data)
	// for size-- {
	for i := 0; i < size; i++ {
		// *hash = (*hash ^ *p++) * 16777619
		 *hash = (*hash ^ p[i]) * 16777619
	}
}

pub fn mu_get_id(ctx &Mu_Context, data voidptr, size int) Mu_Id {
	idx := ctx.id_stack.idx
	res := if (idx > 0) { ctx.id_stack.items[idx - 1] } else { 2166136261 }
	hash(&res, data, size)
	ctx.last_id = res
	return res
}

pub fn mu_push_id(ctx &Mu_Context, data voidptr, size int) {
	(ctx.id_stack).items[(ctx.id_stack).idx] = (mu_get_id(ctx, data, size))
	(ctx.id_stack).idx++
	assert ctx.id_stack.idx < ctx.id_stack.items.len;
}

pub fn mu_pop_id(ctx &Mu_Context) {
	(ctx.id_stack).idx--
	assert ctx.id_stack.idx > 0;
}

pub fn mu_push_clip_rect(ctx &Mu_Context, rect Mu_Rect) {
	last := mu_get_clip_rect(ctx)
	(ctx.clip_stack).items[(ctx.clip_stack).idx] = (intersect_rects(rect, last))
	(ctx.clip_stack).idx++
	assert ((ctx.clip_stack).idx < ctx.clip_stack.items.len);
}

pub fn mu_pop_clip_rect(ctx &Mu_Context) {
	for {
		assert ((ctx.clip_stack).idx > 0);
		(ctx.clip_stack).idx--
	}
}

pub fn mu_get_clip_rect(ctx &Mu_Context) Mu_Rect {
	assert (ctx.clip_stack.idx > 0);
	return ctx.clip_stack.items[ctx.clip_stack.idx - 1]
}

pub fn mu_check_clip(ctx &Mu_Context, r Mu_Rect) int {
	cr := mu_get_clip_rect(ctx)
	if r.x > cr.x + cr.w || r.x + r.w < cr.x || r.y > cr.y + cr.h || r.y + r.h < cr.y {
		return mu_clip_all
	}
	if r.x >= cr.x && r.x + r.w <= cr.x + cr.w && r.y >= cr.y && r.y + r.h <= cr.y + cr.h {
		return 0
	}
	return mu_clip_part
}

pub fn push_layout(ctx &Mu_Context, body Mu_Rect, scroll Mu_Vec2) {
	layout := Mu_Layout{}
	width := 0
	C.memset(&layout, 0, sizeof(layout))
	layout.body = mu_rect(body.x - scroll.x, body.y - scroll.y, body.w, body.h)
	layout.max = mu_vec2(-16777216, -16777216)

	(ctx.layout_stack).items[(ctx.layout_stack).idx] = layout
	(ctx.layout_stack).idx++
	assert (ctx.layout_stack).idx < ctx.layout_stack.items.len;

	mu_layout_row_impl(ctx, 1, &width, 0)
}

pub fn get_layout(ctx &Mu_Context) &Mu_Layout {
	return &ctx.layout_stack.items[ctx.layout_stack.idx - 1]
}

pub fn pop_container(ctx &Mu_Context) {
	cnt := mu_get_current_container(ctx)
	layout := get_layout(ctx)
	cnt.content_size.x = layout.max.x - layout.body.x
	cnt.content_size.y = layout.max.y - layout.body.y;
	// pop container, layout and id
	(ctx.container_stack).idx--;
	assert ((ctx.container_stack).idx > 0);

	(ctx.layout_stack).idx--
	assert (ctx.layout_stack).idx > 0;

	mu_pop_id(ctx)
}

pub fn mu_get_current_container(ctx &Mu_Context) &Mu_Container {
	assert ctx.container_stack.idx > 0
	return ctx.container_stack.items[ctx.container_stack.idx - 1]
}

pub fn get_container(ctx &Mu_Context, id Mu_Id, opt int) ?&Mu_Container {
	cnt := &Mu_Container(0)
	// try to get existing container from pool
	idx := mu_pool_get(ctx, ctx.container_pool, 48, id)
	if idx >= 0 {
		if ctx.containers[idx].open || ~opt & mu_opt_closed {
			mu_pool_update(ctx, ctx.container_pool, idx)
		}
		return &ctx.containers[idx]
	}
	if opt & mu_opt_closed {
		return none
	}
	// container not found in pool: init new container
	idx = mu_pool_init(ctx, ctx.container_pool, 48, id)
	cnt = &ctx.containers[idx]
	C.memset(cnt, 0, sizeof(*cnt))
	cnt.open = true
	mu_bring_to_front(ctx, cnt)
	return cnt
}

pub fn mu_get_container(ctx &Mu_Context, name &i8) ?&Mu_Container {
	id := mu_get_id(ctx, name, C.strlen(name))
	return get_container(ctx, id, 0)
}

pub fn mu_bring_to_front(ctx &Mu_Context, cnt &Mu_Container) {
	cnt.zindex = ctx.last_zindex++$
}

//============================================================================
//* pool
//*============================================================================
pub fn mu_pool_init(ctx &Mu_Context, items &Mu_PoolItem, len int, id Mu_Id) int {
	i := 0
	n := -1
	f := ctx.frame

	for i = 0; i < len; i++ {
		if items[i].last_update < f {
			f = items[i].last_update
			n = i
		}
	}
	assert n > -1;
	items[n].id = id
	mu_pool_update(ctx, items, n)
	return n
}

pub fn mu_pool_get(ctx &Mu_Context, items &Mu_PoolItem, len int, id Mu_Id) int {
	i := 0
	// (void((ctx)))
	for i = 0; i < len; i++ {
		if items[i].id == id {
			return i
		}
	}
	return -1
}

pub fn mu_pool_update(ctx &Mu_Context, items &Mu_PoolItem, idx int) {
	items[idx].last_update = ctx.frame
}

//============================================================================
//* input handlers
//*============================================================================
pub fn mu_input_mousemove(ctx &Mu_Context, x int, y int) {
	ctx.mouse_pos = mu_vec2(x, y)
}

pub fn mu_input_mousedown(ctx &Mu_Context, x int, y int, btn int) {
	mu_input_mousemove(ctx, x, y)
	ctx.mouse_down |= btn
	ctx.mouse_pressed |= btn
}

pub fn mu_input_mouseup(ctx &Mu_Context, x int, y int, btn int) {
	mu_input_mousemove(ctx, x, y)
	ctx.mouse_down &= ~btn
}

pub fn mu_input_scroll(ctx &Mu_Context, x int, y int) {
	ctx.scroll_delta.x += x
	ctx.scroll_delta.y += y
}

pub fn mu_input_keydown(ctx &Mu_Context, key int) {
	ctx.key_pressed |= key
	ctx.key_down |= key
}

pub fn mu_input_keyup(ctx &Mu_Context, key int) {
	ctx.key_down &= ~key
}

pub fn mu_input_text(ctx &Mu_Context, text &i8) {
	len := C.strlen(ctx.input_text)
	size := C.strlen(text) + 1
	assert (len + size <= int(sizeof(ctx.input_text)));
	C.memcpy(ctx.input_text + len, text, size)
}

//============================================================================
//* commandlist
//*============================================================================
pub fn mu_push_command(ctx &Mu_Context, type_ int, size int) &Mu_Command {
	cmd := unsafe { &Mu_Command(&int(ctx.command_list.items) + ctx.command_list.idx) }
	assert (ctx.command_list.idx + size < (256 * 1024));
	cmd.base.type_ = type_
	cmd.base.size = size
	ctx.command_list.idx += size
	return cmd
}

pub fn mu_next_command(ctx &Mu_Context, cmd &&Mu_Command) bool {
	if *cmd {
		*cmd = unsafe { &Mu_Command(((&int(*cmd)) + (*cmd).base.size)) }
	} else {
		*cmd = unsafe { &Mu_Command(&int(ctx.command_list.items)) }
	}
	for unsafe {&i8(*cmd)} != ctx.command_list.items + ctx.command_list.idx {
		if (*cmd).type_ != mu_command_jump {
			return true
		}
		*cmd = (*cmd).jump.dst
	}
	return false
}

pub fn push_jump(ctx &Mu_Context, dst &Mu_Command) &Mu_Command {
	cmd := &Mu_Command(0)
	cmd = mu_push_command(ctx, mu_command_jump, sizeof(Mu_JumpCommand))
	cmd.jump.dst = dst
	return cmd
}

pub fn mu_set_clip(ctx &Mu_Context, rect Mu_Rect) {
	cmd := &Mu_Command(0)
	cmd = mu_push_command(ctx, mu_command_clip, sizeof(Mu_ClipCommand))
	cmd.clip.rect = rect
}

pub fn mu_draw_rect(ctx &Mu_Context, rect Mu_Rect, color Mu_Color) {
	cmd := &Mu_Command(0)
	rect = intersect_rects(rect, mu_get_clip_rect(ctx))
	if rect.w > 0 && rect.h > 0 {
		cmd = mu_push_command(ctx, mu_command_rect, sizeof(Mu_RectCommand))
		cmd.rect.rect = rect
		cmd.rect.color = color
	}
}

pub fn mu_draw_box(ctx &Mu_Context, rect Mu_Rect, color Mu_Color) {
	mu_draw_rect(ctx, mu_rect(rect.x + 1, rect.y, rect.w - 2, 1), color)
	mu_draw_rect(ctx, mu_rect(rect.x + 1, rect.y + rect.h - 1, rect.w - 2, 1), color)
	mu_draw_rect(ctx, mu_rect(rect.x, rect.y, 1, rect.h), color)
	mu_draw_rect(ctx, mu_rect(rect.x + rect.w - 1, rect.y, 1, rect.h), color)
}

pub fn mu_draw_text(ctx &Mu_Context, font Mu_Font, str &i8, len int, pos Mu_Vec2, color Mu_Color) {
	cmd := &Mu_Command(0)
	rect := mu_rect(pos.x, pos.y, ctx.text_width(font, str, len), ctx.text_height(font))
	clipped := mu_check_clip(ctx, rect)
	if clipped == mu_clip_all {
		return
	}
	if clipped == mu_clip_part {
		mu_set_clip(ctx, mu_get_clip_rect(ctx))
	}
	// add command
	if len < 0 {
		len = C.strlen(str)
	}
	s := int(sizeof(Mu_TextCommand))
	cmd = mu_push_command(ctx, mu_command_text, s + len)
	C.memcpy(cmd.text.str, str, len)
	cmd.text.str[len] = `\0`
	cmd.text.pos = pos
	cmd.text.color = color
	cmd.text.font = font
	// reset clipping if it was set
	if clipped {
		mu_set_clip(ctx, unclipped_rect)
	}
}

pub fn mu_draw_icon(ctx &Mu_Context, id int, rect Mu_Rect, color Mu_Color) {
	cmd := &Mu_Command(0)
	// do clip command if the rect isn't fully contained within the cliprect
	clipped := mu_check_clip(ctx, rect)
	if clipped == mu_clip_all {
		return
	}
	if clipped == mu_clip_part {
		mu_set_clip(ctx, mu_get_clip_rect(ctx))
	}
	// do icon command
	cmd = mu_push_command(ctx, mu_command_icon, sizeof(Mu_IconCommand))
	cmd.icon.id = id
	cmd.icon.rect = rect
	cmd.icon.color = color
	// reset clipping if it was set
	if clipped {
		mu_set_clip(ctx, unclipped_rect)
	}
}

//============================================================================
//* layout
//*============================================================================

// empty enum
pub const relative = 1
pub const absolute = 2

pub fn mu_layout_begin_column(ctx &Mu_Context) {
	push_layout(ctx, mu_layout_next(ctx), mu_vec2(0, 0))
}

pub fn mu_layout_end_column(ctx &Mu_Context) {
	a := &Mu_Layout(0)
	b := &Mu_Layout(0)

	b = get_layout(ctx)

	(ctx.layout_stack).idx--
	assert (ctx.layout_stack).idx > 0;

	// inherit position/next_row/max from child layout if they are greater
	a = get_layout(ctx)
	a.position.x = (if (a.position.x) > (b.position.x + b.body.x - a.body.x) {
		(a.position.x)
	} else {
		(b.position.x + b.body.x - a.body.x)
	})
	a.next_row = (if (a.next_row) > (b.next_row + b.body.y - a.body.y) {
		(a.next_row)
	} else {
		(b.next_row + b.body.y - a.body.y)
	})
	a.max.x = (if (a.max.x) > (b.max.x) { (a.max.x) } else { (b.max.x) })
	a.max.y = (if (a.max.y) > (b.max.y) { (a.max.y) } else { (b.max.y) })
}

pub fn mu_layout_row(ctx &Mu_Context, items int, widths []int, height int) {
	mu_layout_row_impl(ctx, items, widths, height)
}

fn mu_layout_row_impl(ctx &Mu_Context, items int, widths &int, height int) {
	layout := get_layout(ctx)
	s := int(sizeof(widths[0]))
	// s := 4
	if widths {
		C.memcpy(layout.widths, widths, items * s)
		assert items <= 16
	}
	layout.items = items
	layout.position = mu_vec2(layout.indent, layout.next_row)
	layout.size.y = height
	layout.item_index = 0
}

pub fn mu_layout_width(ctx &Mu_Context, width int) {
	get_layout(ctx).size.x = width
}

pub fn mu_layout_height(ctx &Mu_Context, height int) {
	get_layout(ctx).size.y = height
}

pub fn mu_layout_set_next(ctx &Mu_Context, r Mu_Rect, relative int) {
	layout := get_layout(ctx)
	layout.next = r
	layout.next_type = if relative { relative } else { absolute }
}

pub fn mu_layout_next(ctx &Mu_Context) Mu_Rect {
	layout := get_layout(ctx)
	style := ctx.style
	res := Mu_Rect{}
	if layout.next_type {
		// handle rect set by `mu_layout_set_next`
		type_ := layout.next_type
		layout.next_type = 0
		res = layout.next
		if type_ == absolute {
			ctx.last_rect = res
			return res
		}
	} else {
		// handle next row
		if layout.item_index == layout.items {
			mu_layout_row_impl(ctx, layout.items, (unsafe { nil }), layout.size.y)
		}
		// position
		res.x = layout.position.x
		res.y = layout.position.y
		// size
		res.w = if layout.items > 0 { layout.widths[layout.item_index] } else { layout.size.x }
		res.h = layout.size.y
		if res.w == 0 {
			res.w = style.size.x + style.padding * 2
		}
		if res.h == 0 {
			res.h = style.size.y + style.padding * 2
		}
		if res.w < 0 {
			res.w += layout.body.w - res.x + 1
		}
		if res.h < 0 {
			res.h += layout.body.h - res.y + 1
		}
		layout.item_index++
	}
	// update position
	layout.position.x += res.w + style.spacing
	layout.next_row = (if (layout.next_row) > (res.y + res.h + style.spacing) {
		(layout.next_row)
	} else {
		(res.y + res.h + style.spacing)
	})
	// apply body offset
	res.x += layout.body.x
	res.y += layout.body.y
	// update max position
	layout.max.x = (if (layout.max.x) > (res.x + res.w) { (layout.max.x) } else { (res.x + res.w) })
	layout.max.y = (if (layout.max.y) > (res.y + res.h) { (layout.max.y) } else { (res.y + res.h) })
	ctx.last_rect = res
	return res
}

//============================================================================
//* controls
//*============================================================================
pub fn in_hover_root(ctx &Mu_Context) bool {
	i := ctx.container_stack.idx
	for i-- {
		if ctx.container_stack.items[i] == ctx.hover_root {
			return true
		}
		// only root containers have their `head` field set; stop searching if we've
		//    * reached the current root container
		if ctx.container_stack.items[i].head {
			break
		}
	}
	return false
}

pub fn mu_draw_control_frame(ctx &Mu_Context, id Mu_Id, rect Mu_Rect, colorid int, opt int) {
	if opt & mu_opt_noframe {
		return
	}
	colorid += if (ctx.focus == id) {
		2
	} else {
		if (ctx.hover == id) { 1 } else { 0 }
	}
	ctx.draw_frame(ctx, rect, colorid)
}

pub fn mu_draw_control_text(ctx &Mu_Context, str &i8, rect Mu_Rect, colorid int, opt int) {
	pos := Mu_Vec2{}
	font := ctx.style.font
	tw := ctx.text_width(font, str, -1)
	mu_push_clip_rect(ctx, rect)
	pos.y = rect.y + (rect.h - ctx.text_height(font)) / 2
	if opt & mu_opt_aligncenter {
		pos.x = rect.x + (rect.w - tw) / 2
	} else if opt & mu_opt_alignright {
		pos.x = rect.x + rect.w - tw - ctx.style.padding
	} else {
		pos.x = rect.x + ctx.style.padding
	}
	mu_draw_text(ctx, font, str, -1, pos, ctx.style.colors[colorid])
	mu_pop_clip_rect(ctx)
}

pub fn mu_mouse_over(ctx &Mu_Context, rect Mu_Rect) bool {
	return rect_overlaps_vec2(rect, ctx.mouse_pos)
		&& rect_overlaps_vec2(mu_get_clip_rect(ctx), ctx.mouse_pos) && in_hover_root(ctx)
}

pub fn mu_update_control(ctx &Mu_Context, id Mu_Id, rect Mu_Rect, opt int) {
	mouseover := mu_mouse_over(ctx, rect)
	if ctx.focus == id {
		ctx.updated_focus = 1
	}
	if opt & mu_opt_nointeract {
		return
	}
	if mouseover && !ctx.mouse_down {
		ctx.hover = id
	}
	if ctx.focus == id {
		if ctx.mouse_pressed && !mouseover {
			mu_set_focus(ctx, 0)
		}
		if !ctx.mouse_down && ~opt & mu_opt_holdfocus {
			mu_set_focus(ctx, 0)
		}
	}
	if ctx.hover == id {
		if ctx.mouse_pressed {
			mu_set_focus(ctx, id)
		} else if !mouseover {
			ctx.hover = 0
		}
	}
}

pub fn mu_text(ctx &Mu_Context, text &i8) {
	start := &i8(0)
	end := &i8(0)
	p := text

	width := -1
	font := ctx.style.font
	color := ctx.style.colors[int(mu_color_text)]
	mu_layout_begin_column(ctx)
	mu_layout_row_impl(ctx, 1, &width, ctx.text_height(font))
	for {
		r := mu_layout_next(ctx)
		w := 0
		start = p
		end = start
		for {
			word := p
			for *p && *p != ' ' && *p != '\n' {
				p++
			}
			w += ctx.text_width(font, word, p - word)
			if w > r.w && end != start {
				break
			}
			w += ctx.text_width(font, p, 1)
			end = p++
			// while()
			if !(*end && *end != '\n') {
				break
			}
		}
		mu_draw_text(ctx, font, start, end - start, mu_vec2(r.x, r.y), color)
		p = end + 1
		// while()
		if !(*end) {
			break
		}
	}
	mu_layout_end_column(ctx)
}

pub fn mu_label(ctx &Mu_Context, text string) {
	text_i8 := text.bytes().map(i8(it))
	mu_draw_control_text(ctx, text_i8, mu_layout_next(ctx), mu_color_text, 0)
}

pub fn mu_button_ex(ctx &Mu_Context, label &i8, icon int, opt int) int {
	res := 0
	id := if label {
		mu_get_id(ctx, label, C.strlen(label))
	} else {
		mu_get_id(ctx, &icon, sizeof(icon))
	}
	r := mu_layout_next(ctx)
	mu_update_control(ctx, id, r, opt)
	// handle click
	if ctx.mouse_pressed == mu_mouse_left && ctx.focus == id {
		res |= mu_res_submit
	}
	// draw
	mu_draw_control_frame(ctx, id, r, mu_color_button, opt)
	if label {
		mu_draw_control_text(ctx, label, r, mu_color_text, opt)
	}
	if icon {
		mu_draw_icon(ctx, icon, r, ctx.style.colors[int(mu_color_text)])
	}
	return res
}

pub fn mu_checkbox(ctx &Mu_Context, label &i8, state &int) int {
	res := 0
	id := mu_get_id(ctx, &state, sizeof(state))
	r := mu_layout_next(ctx)
	box := mu_rect(r.x, r.y, r.h, r.h)
	mu_update_control(ctx, id, r, 0)
	// handle click
	if ctx.mouse_pressed == mu_mouse_left && ctx.focus == id {
		res |= mu_res_change
		*state = !*state
	}
	// draw
	mu_draw_control_frame(ctx, id, box, mu_color_base, 0)
	if *state {
		mu_draw_icon(ctx, mu_icon_check, box, ctx.style.colors[int(mu_color_text)])
	}
	r = mu_rect(r.x + box.w, r.y, r.w - box.w, r.h)
	mu_draw_control_text(ctx, label, r, mu_color_text, 0)
	return res
}

pub fn mu_textbox_raw(ctx &Mu_Context, buf &i8, bufsz int, id Mu_Id, r Mu_Rect, opt int) int {
	res := 0
	mu_update_control(ctx, id, r, opt | mu_opt_holdfocus)
	if ctx.focus == id {
		// handle text input
		len := C.strlen(buf)
		n := (if (bufsz - len - 1) < (int(C.strlen(ctx.input_text))) {
			(bufsz - len - 1)
		} else {
			(int(C.strlen(ctx.input_text)))
		})
		if n > 0 {
			C.memcpy(buf + len, ctx.input_text, n)
			len += n
			buf[len] = `\0`
			res |= mu_res_change
		}
		// handle backspace
		if ctx.key_pressed & mu_key_backspace && len > 0 {
			// skip utf-8 continuation bytes
			for (buf[len--$] & 192) == 128 && len > 0 {
				0
			}
			buf[len] = `\0`
			res |= mu_res_change
		}
		// handle return
		if ctx.key_pressed & mu_key_return {
			mu_set_focus(ctx, 0)
			res |= mu_res_submit
		}
	}
	// draw
	mu_draw_control_frame(ctx, id, r, mu_color_base, opt)
	if ctx.focus == id {
		color := ctx.style.colors[int(mu_color_text)]
		font := ctx.style.font
		textw := ctx.text_width(font, buf, -1)
		texth := ctx.text_height(font)
		ofx := r.w - ctx.style.padding - textw - 1
		textx := r.x + (if ofx < (ctx.style.padding) { ofx } else { (ctx.style.padding) })
		texty := r.y + (r.h - texth) / 2
		mu_push_clip_rect(ctx, r)
		mu_draw_text(ctx, font, buf, -1, mu_vec2(textx, texty), color)
		mu_draw_rect(ctx, mu_rect(textx + textw, texty, 1, texth), color)
		mu_pop_clip_rect(ctx)
	} else {
		mu_draw_control_text(ctx, buf, r, mu_color_text, opt)
	}
	return res
}

pub fn number_textbox(ctx &Mu_Context, value &Mu_Real, r Mu_Rect, id Mu_Id) int {
	if ctx.mouse_pressed == mu_mouse_left && ctx.key_down & mu_key_shift && ctx.hover == id {
		ctx.number_edit = id
		C.sprintf(ctx.number_edit_buf, c'%.3g', *value)
	}
	if ctx.number_edit == id {
		res := mu_textbox_raw(ctx, ctx.number_edit_buf, sizeof(ctx.number_edit_buf), id,
			r, 0)
		if res & mu_res_submit || ctx.focus != id {
			buf := ctx.number_edit_buf.map(u8(it))[..]
			s := buf.bytestr()
			*value = strconv.atof64(s) or { unsafe {nil} }
			ctx.number_edit = 0
		} else {
			return 1
		}
	}
	return 0
}

pub fn mu_textbox_ex(ctx &Mu_Context, buf &i8, bufsz int, opt int) int {
	id := mu_get_id(ctx, &buf, sizeof(buf))
	r := mu_layout_next(ctx)
	return mu_textbox_raw(ctx, buf, bufsz, id, r, opt)
}

pub fn mu_slider_ex(ctx &Mu_Context, value &Mu_Real, low Mu_Real, high Mu_Real, step Mu_Real, fmt &i8, opt int) int {
	buf := [128]i8{}
	thumb := Mu_Rect{}
	x := 0
	w := 0
	res := 0

	last := *value
	v := last

	id := mu_get_id(ctx, &value, sizeof(value))
	base := mu_layout_next(ctx)
	// handle text input mode
	if number_textbox(ctx, &v, base, id) {
		return res
	}
	// handle normal mode
	mu_update_control(ctx, id, base, opt)
	// handle input
	if ctx.focus == id && (ctx.mouse_down | ctx.mouse_pressed) == mu_mouse_left {
		v = low + (ctx.mouse_pos.x - base.x) * (high - low) / base.w
		if step {
			v = (i64(((v + step / 2) / step))) * step
		}
	}
	// clamp and store value, update res
	*value = (if high < (if low > v { low } else { v }) { high
	 } else { (if low > v { low } else { v })
	 })
	v = *value
	if last != v {
		res |= mu_res_change
	}
	// draw base
	mu_draw_control_frame(ctx, id, base, mu_color_base, opt)
	// draw thumb
	w = ctx.style.thumb_size
	x = (v - low) * (base.w - w) / (high - low)
	thumb = mu_rect(base.x + x, base.y, w, base.h)
	mu_draw_control_frame(ctx, id, thumb, mu_color_button, opt)
	// draw text
	C.sprintf(buf, fmt, v)
	mu_draw_control_text(ctx, buf, base, mu_color_text, opt)
	return res
}

pub fn mu_number_ex(ctx &Mu_Context, value &Mu_Real, step Mu_Real, fmt &i8, opt int) int {
	buf := [128]i8{}
	res := 0
	id := mu_get_id(ctx, &value, sizeof(value))
	base := mu_layout_next(ctx)
	last := *value
	// handle text input mode
	if number_textbox(ctx, value, base, id) {
		return res
	}
	// handle normal mode
	mu_update_control(ctx, id, base, opt)
	// handle input
	if ctx.focus == id && ctx.mouse_down == mu_mouse_left {
		*value += ctx.mouse_delta.x * step
	}
	// set flag if value changed
	if *value != last {
		res |= mu_res_change
	}
	// draw base
	mu_draw_control_frame(ctx, id, base, mu_color_base, opt)
	// draw text
	C.sprintf(buf, fmt, *value)
	mu_draw_control_text(ctx, buf, base, mu_color_text, opt)
	return res
}

pub fn header(ctx &Mu_Context, label &i8, istreenode int, opt int) int {
	r := Mu_Rect{}
	active := 0
	expanded := 0

	id := mu_get_id(ctx, label, C.strlen(label))
	idx := mu_pool_get(ctx, ctx.treenode_pool, 48, id)
	width := -1
	mu_layout_row_impl(ctx, 1, &width, 0)
	active = (idx >= 0)
	expanded = if (opt & mu_opt_expanded) { !active } else { active }
	r = mu_layout_next(ctx)
	mu_update_control(ctx, id, r, 0)
	// handle click
	active ^= (ctx.mouse_pressed == mu_mouse_left && ctx.focus == id)
	// update pool ref
	if idx >= 0 {
		if active {
			mu_pool_update(ctx, ctx.treenode_pool, idx)
		} else {
			C.memset(&ctx.treenode_pool[idx], 0, sizeof(Mu_PoolItem))
		}
	} else if active {
		mu_pool_init(ctx, ctx.treenode_pool, 48, id)
	}
	// draw
	if istreenode {
		if ctx.hover == id {
			ctx.draw_frame(ctx, r, mu_color_buttonhover)
		}
	} else {
		mu_draw_control_frame(ctx, id, r, mu_color_button, 0)
	}
	mu_draw_icon(ctx, if expanded { mu_icon_expanded } else { mu_icon_collapsed }, mu_rect(r.x,
		r.y, r.h, r.h), ctx.style.colors[int(mu_color_text)])
	r.x += r.h - ctx.style.padding
	r.w -= r.h - ctx.style.padding
	mu_draw_control_text(ctx, label, r, mu_color_text, 0)
	return if expanded { mu_res_active } else { 0 }
}

pub fn mu_header_ex(ctx &Mu_Context, label &i8, opt int) int {
	return header(ctx, label, 0, opt)
}

pub fn mu_begin_treenode_ex(ctx &Mu_Context, label &i8, opt int) int {
	res := header(ctx, label, 1, opt)
	if res & mu_res_active {
		get_layout(ctx).indent += ctx.style.indent;
		(ctx.id_stack).items[(ctx.id_stack).idx] = (ctx.last_id)
		(ctx.id_stack).idx++
		assert (ctx.id_stack).idx < ctx.id_stack.items.len;
	}
	return res
}

pub fn mu_end_treenode(ctx &Mu_Context) {
	get_layout(ctx).indent -= ctx.style.indent
	mu_pop_id(ctx)
}

// only add scrollbar if content size is larger than body
// get sizing / positioning
// handle input
// clamp scroll to limits
// draw base and thumb
// set this as the scroll_target (will get scrolled on mousewheel)
// if the mouse is over it
pub fn scrollbars(ctx &Mu_Context, cnt &Mu_Container, body &Mu_Rect) {
	sz := ctx.style.scrollbar_size
	cs := cnt.content_size
	cs.x += ctx.style.padding * 2
	cs.y += ctx.style.padding * 2
	mu_push_clip_rect(ctx, *body)
	// resize body to make room for scrollbars
	if cs.y > cnt.body.h {
		body.w -= sz
	}
	if cs.x > cnt.body.w {
		body.h -= sz
	}
	// to create a horizontal or vertical scrollbar almost-identical code is
	//  * used; only the references to `x|y` `w|h` need to be switched
	for {
		maxscroll := cs.y - body.h
		if maxscroll > 0 && body.h > 0 {
			base := Mu_Rect{}
			thumb := Mu_Rect{}

			id := mu_get_id(ctx, c'!scrollbary', 11)
			base = *body
			base.x = body.x + body.w
			base.w = ctx.style.scrollbar_size
			mu_update_control(ctx, id, base, 0)
			if ctx.focus == id && ctx.mouse_down == mu_mouse_left {
				cnt.scroll.y += ctx.mouse_delta.y * cs.y / base.h
			}
			cnt.scroll.y = (if maxscroll < (if (0) > (cnt.scroll.y) { (0) } else { (cnt.scroll.y) }) { maxscroll
			 } else { (if (0) > (cnt.scroll.y) { (0) } else { (cnt.scroll.y) })
			 })
			ctx.draw_frame(ctx, base, mu_color_scrollbase)
			thumb = base
			thumb.h = (if (ctx.style.thumb_size) > (base.h * body.h / cs.y) {
				(ctx.style.thumb_size)
			} else {
				(base.h * body.h / cs.y)
			})
			thumb.y += cnt.scroll.y * (base.h - thumb.h) / maxscroll
			ctx.draw_frame(ctx, thumb, mu_color_scrollthumb)
			if mu_mouse_over(ctx, *body) {
				ctx.scroll_target = cnt
			}
		} else {
			cnt.scroll.y = 0
		}
		// while()
		if !(0) {
			break
		}
	}
	for {
		maxscroll := cs.x - body.w
		if maxscroll > 0 && body.w > 0 {
			base := Mu_Rect{}
			thumb := Mu_Rect{}

			id := mu_get_id(ctx, c'!scrollbarx', 11)
			base = *body
			base.y = body.y + body.h
			base.h = ctx.style.scrollbar_size
			mu_update_control(ctx, id, base, 0)
			if ctx.focus == id && ctx.mouse_down == mu_mouse_left {
				cnt.scroll.x += ctx.mouse_delta.x * cs.x / base.w
			}
			cnt.scroll.x = (if maxscroll < (if (0) > (cnt.scroll.x) { (0) } else { (cnt.scroll.x) }) { maxscroll
			 } else { (if (0) > (cnt.scroll.x) { (0) } else { (cnt.scroll.x) })
			 })
			ctx.draw_frame(ctx, base, mu_color_scrollbase)
			thumb = base
			thumb.w = (if (ctx.style.thumb_size) > (base.w * body.w / cs.x) {
				(ctx.style.thumb_size)
			} else {
				(base.w * body.w / cs.x)
			})
			thumb.x += cnt.scroll.x * (base.w - thumb.w) / maxscroll
			ctx.draw_frame(ctx, thumb, mu_color_scrollthumb)
			if mu_mouse_over(ctx, *body) {
				ctx.scroll_target = cnt
			}
		} else {
			cnt.scroll.x = 0
		}
		// while()
		if !(0) {
			break
		}
	}
	mu_pop_clip_rect(ctx)
}

pub fn push_container_body(ctx &Mu_Context, cnt &Mu_Container, body Mu_Rect, opt int) {
	if ~opt & mu_opt_noscroll {
		scrollbars(ctx, cnt, &body)
	}
	push_layout(ctx, expand_rect(body, -ctx.style.padding), cnt.scroll)
	cnt.body = body
}

pub fn begin_root_container(ctx &Mu_Context, cnt &Mu_Container) {
	(ctx.container_stack).items[(ctx.container_stack).idx] = cnt
	(ctx.container_stack).idx++
	assert (ctx.container_stack).idx < ctx.container_stack.items.len;

	// push container to roots list and push head command
	(ctx.root_list).items[(ctx.root_list).idx] = cnt
	(ctx.root_list).idx++
	assert (ctx.root_list).idx < ctx.root_list.items.len;

	cnt.head = push_jump(ctx, (unsafe { nil }))
	// set as hover root if the mouse is overlapping this container and it has a
	//  * higher zindex than the current hover root
	if rect_overlaps_vec2(cnt.rect, ctx.mouse_pos)
		&& (!ctx.next_hover_root || cnt.zindex > ctx.next_hover_root.zindex) {
		ctx.next_hover_root = cnt
	}
	// clipping is reset here in case a root-container is made within
	//  * another root-containers's begin/end block; this prevents the inner
	//  * root-container being clipped to the outer
	for {
		assert ctx.clip_stack.idx < ctx.clip_stack.items.len;

		(ctx.clip_stack).items[(ctx.clip_stack).idx] = unclipped_rect
		(ctx.clip_stack).idx++
	}
}

pub fn end_root_container(ctx &Mu_Context) {
	// push tail 'goto' jump command and set head 'skip' command. the final steps
	//  * on initing these are done in mu_end()
	cnt := mu_get_current_container(ctx)
	cnt.tail = push_jump(ctx, (unsafe { nil }))
	cnt.head.jump.dst = ctx.command_list.items + ctx.command_list.idx
	// pop base clip rect and container
	mu_pop_clip_rect(ctx)
	pop_container(ctx)
}

pub fn mu_begin_window_ex(ctx &Mu_Context, title string, rect Mu_Rect, opt int) bool {
	ctitle := c'${title}'
	return mu_begin_window_ex_impl(ctx, &ctitle, rect, opt)
}

fn mu_begin_window_ex_impl(ctx &Mu_Context, title &u8, rect Mu_Rect, opt int) bool {
	body := Mu_Rect{}
	id := mu_get_id(ctx, title, C.strlen(title))
	cnt := get_container(ctx, id, opt) or { return false }
	if !cnt.open {
		return false
	}

	(ctx.id_stack).items[(ctx.id_stack).idx] = id
	(ctx.id_stack).idx++
	assert (ctx.id_stack).idx < ctx.id_stack.items.len;

	if cnt.rect.w == 0 {
		cnt.rect = rect
	}
	begin_root_container(ctx, cnt)
	rect = cnt.rect
	body = rect
	// draw frame
	if ~opt & mu_opt_noframe {
		ctx.draw_frame(ctx, rect, mu_color_windowbg)
	}
	// do title bar
	if ~opt & mu_opt_notitle {
		tr := rect
		tr.h = ctx.style.title_height
		ctx.draw_frame(ctx, tr, mu_color_titlebg)
		// do title text
		if ~opt & mu_opt_notitle {
			id2 := mu_get_id(ctx, c'!title', 6)
			mu_update_control(ctx, id2, tr, opt)
			mu_draw_control_text(ctx, title, tr, mu_color_titletext, opt)
			if id2 == ctx.focus && ctx.mouse_down == mu_mouse_left {
				cnt.rect.x += ctx.mouse_delta.x
				cnt.rect.y += ctx.mouse_delta.y
			}
			body.y += tr.h
			body.h -= tr.h
		}
		// do `close` button
		if ~opt & mu_opt_noclose {
			id3 := mu_get_id(ctx, c'!close', 6)
			r := mu_rect(tr.x + tr.w - tr.h, tr.y, tr.h, tr.h)
			tr.w -= r.w
			mu_draw_icon(ctx, mu_icon_close, r, ctx.style.colors[int(mu_color_titletext)])
			mu_update_control(ctx, id3, r, opt)
			if ctx.mouse_pressed == mu_mouse_left && id3 == ctx.focus {
				cnt.open = false
			}
		}
	}
	push_container_body(ctx, cnt, body, opt)
	// do `resize` handle
	if ~opt & mu_opt_noresize {
		sz := ctx.style.title_height
		id4 := mu_get_id(ctx, c'!resize', 7)
		r := mu_rect(rect.x + rect.w - sz, rect.y + rect.h - sz, sz, sz)
		mu_update_control(ctx, id4, r, opt)
		if id4 == ctx.focus && ctx.mouse_down == mu_mouse_left {
			cnt.rect.w = (if (96) > (cnt.rect.w + ctx.mouse_delta.x) {
				(96)
			} else {
				(cnt.rect.w + ctx.mouse_delta.x)
			})
			cnt.rect.h = (if (64) > (cnt.rect.h + ctx.mouse_delta.y) {
				(64)
			} else {
				(cnt.rect.h + ctx.mouse_delta.y)
			})
		}
	}
	// resize to content size
	if opt & mu_opt_autosize {
		r := get_layout(ctx).body
		cnt.rect.w = cnt.content_size.x + (cnt.rect.w - r.w)
		cnt.rect.h = cnt.content_size.y + (cnt.rect.h - r.h)
	}
	// close if this is a popup window and elsewhere was clicked
	if opt & mu_opt_popup && ctx.mouse_pressed && ctx.hover_root != cnt {
		cnt.open = false
	}
	mu_push_clip_rect(ctx, cnt.body)
	return bool(mu_res_active)
}

pub fn mu_end_window(ctx &Mu_Context) {
	mu_pop_clip_rect(ctx)
	end_root_container(ctx)
}

pub fn mu_open_popup(ctx &Mu_Context, name &i8) {
	cnt := mu_get_container(ctx, name) or { panic(err) }
	// set as hover root so popup isn't closed in begin_window_ex()
	ctx.hover_root = cnt
	ctx.next_hover_root = ctx.hover_root
	// position at mouse cursor, open and bring-to-front
	cnt.rect = mu_rect(ctx.mouse_pos.x, ctx.mouse_pos.y, 1, 1)
	cnt.open = true
	mu_bring_to_front(ctx, cnt)
}

pub fn mu_begin_popup(ctx &Mu_Context, name string) bool {
	opt := mu_opt_popup | mu_opt_autosize | mu_opt_noresize | mu_opt_noscroll | mu_opt_notitle | mu_opt_closed
	return mu_begin_window_ex(ctx, name, mu_rect(0, 0, 0, 0), opt)
}

pub fn mu_end_popup(ctx &Mu_Context) {
	mu_end_window(ctx)
}

pub fn mu_begin_panel_ex(ctx &Mu_Context, name &i8, opt int) {
	cnt := &Mu_Container(0)
	mu_push_id(ctx, name, C.strlen(name))
	cnt = get_container(ctx, ctx.last_id, opt) or { panic(err) }
	cnt.rect = mu_layout_next(ctx)
	if ~opt & mu_opt_noframe {
		ctx.draw_frame(ctx, cnt.rect, mu_color_panelbg)
	}

	(ctx.container_stack).items[(ctx.container_stack).idx] = cnt
	(ctx.container_stack).idx++
	assert (ctx.container_stack).idx < ctx.container_stack.items.len;

	push_container_body(ctx, cnt, cnt.rect, opt)
	mu_push_clip_rect(ctx, cnt.body)
}

pub fn mu_end_panel(ctx &Mu_Context) {
	mu_pop_clip_rect(ctx)
	pop_container(ctx)
}
