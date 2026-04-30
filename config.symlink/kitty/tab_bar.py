from kitty.tab_bar import as_rgb

LEFT_EDGE = ''   # /  (lower-right triangle)
RIGHT_EDGE = ''  # \  (lower-left triangle)

BAR_BG = 0x1a1b1e
ACTIVE_BG = 0x3a3b40
ACTIVE_FG = 0xffffff
INACTIVE_BG = 0x26272b
INACTIVE_FG = 0xb8babf

HARD_MAX = 30  # absolute cap on title length, regardless of available space


def draw_tab(draw_data, screen, tab, before, max_title_length, index, is_last, extra_data):
    if tab.is_active:
        bg, fg = ACTIVE_BG, ACTIVE_FG
    else:
        bg, fg = INACTIVE_BG, INACTIVE_FG

    # Truncate title: cap at HARD_MAX and at the per-tab budget kitty gives us
    # (minus 4 chars for the two edges and the surrounding spaces).
    title = tab.title
    budget = max_title_length - 4 if max_title_length > 0 else HARD_MAX
    cap = min(HARD_MAX, max(3, budget))
    if len(title) > cap:
        title = title[:cap - 1] + '…'

    screen.cursor.fg = as_rgb(bg)
    screen.cursor.bg = as_rgb(BAR_BG)
    screen.draw(LEFT_EDGE)

    screen.cursor.fg = as_rgb(fg)
    screen.cursor.bg = as_rgb(bg)
    if tab.is_active:
        screen.cursor.bold = True
    screen.draw(' ' + title + ' ')
    screen.cursor.bold = False

    screen.cursor.fg = as_rgb(bg)
    screen.cursor.bg = as_rgb(BAR_BG)
    screen.draw(RIGHT_EDGE)

    return screen.cursor.x
