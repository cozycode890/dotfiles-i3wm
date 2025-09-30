#!/usr/bin/env python3
import i3ipc, subprocess, re

VSCODE_CLASSES = re.compile(r'^(Code|code-oss|VSCodium)$')
US_ENGINE = "xkb:us::eng"   # đổi nếu bạn dùng US-Intl, v.v.
DEFAULT_ENGINE_CMD = ["ibus", "engine"]

last_engine = None
forced = False

def get_current_engine():
    try:
        out = subprocess.check_output(DEFAULT_ENGINE_CMD, text=True).strip()
        return out
    except:
        return None

def set_engine(e):
    try:
        subprocess.check_call(DEFAULT_ENGINE_CMD + [e])
    except:
        pass

def on_window_focus(i3, e):
    global last_engine, forced
    w = e.container
    cls = (w.window_class or "").strip()
    if VSCODE_CLASSES.match(cls):
        # đang vào VSCode
        cur = get_current_engine()
        if cur and cur != US_ENGINE:
            last_engine = cur
            set_engine(US_ENGINE)
            forced = True
    else:
        # rời VSCode
        if forced and last_engine:
            set_engine(last_engine)
            forced = False

i3 = i3ipc.Connection()
i3.on("window::focus", on_window_focus)
i3.main()
