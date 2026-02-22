from kitty.fast_data_types import Screen
from kitty.tab_bar import (
    DrawData,
    ExtraData,
    TabBarData,
    as_rgb,
    draw_title
)

def draw_tab(
    draw_data: DrawData, screen: Screen, tab: TabBarData,
    before: int, max_tab_length: int, index: int, is_last: bool,
    extra_data: ExtraData
) -> int:
    left_sep, right_sep = ('', '')

    def draw_left_sep() -> None:
        if tab.is_active:
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.active_bg.rgb)
            screen.draw(left_sep)
            screen.cursor.bg = as_rgb(draw_data.active_bg.rgb)
            screen.cursor.fg = as_rgb(draw_data.active_fg.rgb)
        else:
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.inactive_bg.rgb)
            screen.draw(left_sep)
            screen.cursor.bg = as_rgb(draw_data.inactive_bg.rgb)
            screen.cursor.fg = as_rgb(draw_data.inactive_fg.rgb)
    def draw_right_sep() -> None:
        if tab.is_active:
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.active_bg.rgb)
            screen.draw(right_sep)
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.active_fg.rgb)
        else:
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.inactive_bg.rgb)
            screen.draw(right_sep)
            screen.cursor.bg = draw_data.default_bg.rgb
            screen.cursor.fg = as_rgb(draw_data.inactive_fg.rgb)

    if index != 1:
        screen.cursor.bg = draw_data.default_bg.rgb
        screen.cursor.fg = as_rgb(draw_data.active_fg.rgb)
        screen.draw(draw_data.sep)

    max_tab_length += 1
    if max_tab_length <= 1:
        screen.draw('…')
    elif max_tab_length == 2:
        screen.draw('…|')
    elif max_tab_length < 6:
        draw_left_sep()
        screen.draw((' ' if max_tab_length == 5 else '') + '…' + (' ' if max_tab_length >= 4 else ''))
        draw_right_sep()
    else:
        draw_left_sep()
        draw_title(draw_data, screen, tab, index, max_tab_length)
        extra = screen.cursor.x - before - max_tab_length
        screen.cursor.fg = as_rgb(draw_data.active_fg.rgb)
        if extra >= 0:
            screen.cursor.x -= extra + 3
            screen.draw('…')
        elif extra == -1:
            screen.cursor.x -= 2
            screen.draw('…')
        draw_right_sep()

    return screen.cursor.x
