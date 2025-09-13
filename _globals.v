@[translated]
module microui

@[weak] __global unclipped_rect = C.mu_Rect {
x: 0, 
y: 0, 
w: 16777216, 
h: 16777216
}




@[weak] __global default_style = C.mu_Style {
// font | size | padding | spacing | indent 
font: (voidptr(0)), 
size: C.mu_Vec2 {
x: 68, 
y: 10
}
, 
padding: 5, 
spacing: 4, 
indent: 24, 
// title_height | scrollbar_size | thumb_size 
title_height: 24, 
scrollbar_size: 12, 
thumb_size: 8, 
colors: [C.mu_Color {
r: 230, 
g: 230, 
b: 230, 
a: 255
}
, // MU_COLOR_TEXT 
C.mu_Color {
r: 25, 
g: 25, 
b: 25, 
a: 255
}
, // MU_COLOR_BORDER 
C.mu_Color {
r: 50, 
g: 50, 
b: 50, 
a: 255
}
, // MU_COLOR_WINDOWBG 
C.mu_Color {
r: 25, 
g: 25, 
b: 25, 
a: 255
}
, // MU_COLOR_TITLEBG 
C.mu_Color {
r: 240, 
g: 240, 
b: 240, 
a: 255
}
, // MU_COLOR_TITLETEXT 
C.mu_Color {
r: 0, 
g: 0, 
b: 0, 
a: 0
}
, // MU_COLOR_PANELBG 
C.mu_Color {
r: 75, 
g: 75, 
b: 75, 
a: 255
}
, // MU_COLOR_BUTTON 
C.mu_Color {
r: 95, 
g: 95, 
b: 95, 
a: 255
}
, // MU_COLOR_BUTTONHOVER 
C.mu_Color {
r: 115, 
g: 115, 
b: 115, 
a: 255
}
, // MU_COLOR_BUTTONFOCUS 
C.mu_Color {
r: 30, 
g: 30, 
b: 30, 
a: 255
}
, // MU_COLOR_BASE 
C.mu_Color {
r: 35, 
g: 35, 
b: 35, 
a: 255
}
, // MU_COLOR_BASEHOVER 
C.mu_Color {
r: 40, 
g: 40, 
b: 40, 
a: 255
}
, // MU_COLOR_BASEFOCUS 
C.mu_Color {
r: 43, 
g: 43, 
b: 43, 
a: 255
}
, // MU_COLOR_SCROLLBASE 
C.mu_Color {
r: 30, 
g: 30, 
b: 30, 
a: 255
}
, // MU_COLOR_SCROLLTHUMB 
]!

}




