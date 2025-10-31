#!/usr/bin/env python3
import os, sys, json, subprocess, shlex
from pathlib import Path
import i3ipc

TIP_MARK = "__spiral_tip"

def ws_name_of(focused):
    ws = focused.workspace()
    return ws.name if ws else None

def state_path(ws):
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    d = Path(runtime) / "i3-spiral"
    d.mkdir(parents=True, exist_ok=True)
    return d / (ws.replace("/", "_") + ".json")

def load_next_dir(ws):
    p = state_path(ws)
    if p.exists():
        try:
            return json.loads(p.read_text()).get("next", "h")
        except Exception:
            pass
    return "h"  # mặc định bắt đầu ngang

def save_next_dir(ws, nxt):
    p = state_path(ws)
    p.write_text(json.dumps({"next": nxt}))

def main():
    # Lấy lệnh app từ args (sau dấu --)
    if "--" in sys.argv:
        cmd = " ".join(sys.argv[sys.argv.index("--")+1:])
    else:
        # Cho phép truyền trực tiếp: spiral-run.py alacritty
        cmd = " ".join(sys.argv[1:])
    if not cmd:
        print("Usage: spiral-run.py -- <command>")
        sys.exit(1)

    i3 = i3ipc.Connection()
    focused = i3.get_tree().find_focused()
    ws = ws_name_of(focused)
    if not ws:
        sys.exit(0)

    # 1) focus tip nếu có
    i3.command(f'[con_mark="{TIP_MARK}"] focus')

    # 2) split theo chiều luân phiên (lưu trạng thái theo workspace)
    nxt = load_next_dir(ws)  # "h" hoặc "v"
    i3.command("split h" if nxt == "h" else "split v")
    # Lần sau đảo chiều
    save_next_dir(ws, "v" if nxt == "h" else "h")

    # 3) Mở app
    # Dùng shell=True để đơn giản hoá trích dẫn lệnh trong i3 config
    proc = subprocess.Popen(cmd, shell=True)

    # 4) Đợi cửa sổ mới rồi gắn mark tip
    def on_new(_, e):
        w = e.container.workspace()
        if w and w.name == ws:
            # Focus + mark tip cho cửa sổ vừa mở
            e.container.command(f'focus; mark --replace {TIP_MARK}')
            i3.main_quit()

    i3.on("window::new", on_new)
    # Timeout dự phòng (trong trường hợp app daemon hoá không mở window)
    i3.main(timeout=3.0)
    # Kết thúc script, không kill app
    sys.exit(0)

if __name__ == "__main__":
    main()
