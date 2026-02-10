#!/usr/bin/env python3
"""
app workspace manager:
- If app is running: toggle the special workspace visibility
- If app is not running: launch the app (it will open in its assigned workspace via windowrules)
"""

import json
import subprocess
import sys

APPS = {
    "obsidian": ("obsidian", "obsidian", "obsidian"),
    "spotify": ("spotify", "spotify", "spotify"),
    "beeper": ("beeper", "beeper", "BeeperTexts"),
    "discord": ("discord", "discord", "discord"),
    "slack": ("slack", "slack", "Slack"),
}


def run_hyprctl(args: list[str]) -> str:
    """run hyprctl and return output."""
    result = subprocess.run(
        ["hyprctl"] + args,
        capture_output=True,
        text=True,
    )
    return result.stdout


def get_clients() -> list[dict]:
    """Get list of all clients/windows."""
    output = run_hyprctl(["clients", "-j"])
    try:
        return json.loads(output)
    except json.JSONDecodeError:
        return []


def get_app_client(clients: list[dict], window_class: str) -> dict | None:
    """Get the client info for an app with the given window class."""
    for client in clients:
        client_class = client.get("class", "")
        if client_class.lower() == window_class.lower():
            return client
    return None


def is_app_focused(client: dict | None) -> bool:
    """Check if the given client is currently focused."""
    if client is None:
        return False
    return client.get("focusHistoryID", -1) == 0


def get_last_focused_client(clients: list[dict]) -> dict | None:
    """Get the client with focusHistoryID of 1 (previously focused window)."""
    for client in clients:
        if client.get("focusHistoryID", -1) == 1:
            return client
    return None


def is_in_special_workspace(client: dict | None) -> bool:
    """Check if the client is in a special workspace."""
    if client is None:
        return False
    workspace = client.get("workspace", {})
    workspace_name = workspace.get("name", "")
    return workspace_name.startswith("special:")


def toggle_special_workspace(workspace_name: str) -> None:
    run_hyprctl(["dispatch", "togglespecialworkspace", workspace_name])


def focus_window(address: str) -> None:
    """Focus a window by its address."""
    run_hyprctl(["dispatch", "focuswindow", f"address:{address}"])


def toggle_app_workspace(clients: list[dict], app_client: dict | None) -> None:
    """
    Toggle between the app and the previously focused window.
    - If app is focused: focus the window with focusHistoryID of 1
    - If app is not focused: focus the app
    """
    if is_app_focused(app_client):
        last_client = get_last_focused_client(clients)
        if last_client:
            address = last_client.get("address", "")
            if address:
                focus_window(address)
    else:
        if app_client:
            address = app_client.get("address", "")
            if address:
                focus_window(address)


def toggle_app(
    clients: list[dict], window_class: str, workspace_name: str = ""
) -> None:
    """
    Toggles app visibility.
    - If app is in special workspace and workspace_name is provided: toggle special workspace visibility
    - If app is not in special workspace or workspace_name is not provided: toggle between app and last focused window
    """
    app_client = get_app_client(clients, window_class)
    if workspace_name and is_in_special_workspace(app_client):
        toggle_special_workspace(workspace_name)
    else:
        toggle_app_workspace(clients, app_client)


def launch_app_in_workspace(command: str, workspace_name: str) -> None:
    run_hyprctl(["dispatch", "exec", f"[workspace special:{workspace_name}]", command])


def handle_app(app_key: str) -> None:
    if app_key not in APPS:
        print(f"Unknown app: {app_key}", file=sys.stderr)
        sys.exit(1)

    workspace_name, launch_command, window_class = APPS[app_key]
    clients = get_clients()
    app_client = get_app_client(clients, window_class)

    if app_client:
        toggle_app(clients, window_class, workspace_name)
    else:
        launch_app_in_workspace(launch_command, workspace_name)


def main() -> None:
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <app_key>", file=sys.stderr)
        print(f"Available apps: {', '.join(APPS.keys())}", file=sys.stderr)
        sys.exit(1)

    app_key = sys.argv[1].lower()
    handle_app(app_key)


if __name__ == "__main__":
    main()
