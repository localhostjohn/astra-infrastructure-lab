"""Validate and preview a Discord server blueprint. No Discord connection required."""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent
MODES = {"public", "read_only", "staff", "owner"}


def load_layout(path=ROOT / "layout.json"):
    data = json.loads(Path(path).read_text(encoding="utf-8"))
    validate_layout(data)
    return data


def validate_layout(data):
    if not isinstance(data.get("server_name"), str) or not data["server_name"].strip():
        raise ValueError("A server_name is required.")

    roles = data.get("roles", [])
    if not isinstance(roles, list):
        raise ValueError("roles must be a list.")
    role_names = [r["name"] for r in roles]
    if len(role_names) != len(set(role_names)):
        raise ValueError("Duplicate role names.")
    if any("administrator" in r.get("permissions", []) for r in roles):
        raise ValueError("Administrator permission is intentionally prohibited.")

    staff_roles = data.get("staff_roles", [])
    if not isinstance(staff_roles, list):
        raise ValueError("staff_roles must be a list.")
    missing_staff = set(staff_roles) - set(role_names)
    if missing_staff:
        raise ValueError(f"staff_roles reference undefined roles: {sorted(missing_staff)}")

    categories = data.get("categories", [])
    if not isinstance(categories, list):
        raise ValueError("categories must be a list.")
    category_names = [c["name"] for c in categories]
    if len(category_names) != len(set(category_names)):
        raise ValueError("Duplicate category names.")

    names = set()
    text_channels = set()
    for category in categories:
        mode = category.get("mode", "public")
        if mode not in MODES:
            raise ValueError(f"Invalid category mode: {mode}")
        for channel in category.get("channels", []):
            name = channel["name"]
            if name in names:
                raise ValueError(f"Duplicate channel name: {name}")
            names.add(name)
            channel_mode = channel.get("mode", mode)
            if channel_mode not in MODES:
                raise ValueError(f"Invalid mode for {name}")
            if mode in {"staff", "owner"} and channel_mode != mode:
                raise ValueError(f"Private category has a less restrictive child: {name}")
            if channel["kind"] not in {"text", "voice"}:
                raise ValueError(f"Invalid channel kind: {name}")
            if channel["kind"] == "text":
                text_channels.add(name)
            if len(name) > 100:
                raise ValueError(f"Channel name too long: {name}")

    if len(names) + len(category_names) > 500:
        raise ValueError("The blueprint exceeds Discord channel limits.")

    starter_messages = data.get("starter_messages", {})
    if not isinstance(starter_messages, dict):
        raise ValueError("starter_messages must be an object keyed by channel name.")
    if set(starter_messages) - text_channels:
        raise ValueError("A starter message targets a missing/non-text channel.")
    for text in starter_messages.values():
        if set(re.findall(r"\{channel:([^}]+)\}", text)) - text_channels:
            raise ValueError("A starter message references a missing channel.")
        if len(text) > 3900:
            raise ValueError("A starter message is too long for the setup embed.")

    return True


def preview(data):
    lines = [
        f"Server template: {data['server_name']}",
        f"Roles: {len(data.get('roles', []))}",
        f"Categories: {len(data.get('categories', []))}",
        f"Channels: {sum(len(c.get('channels', [])) for c in data.get('categories', []))}",
        f"Starter messages: {len(data.get('starter_messages', {}))}",
        "",
    ]
    for category in data.get("categories", []):
        category_mode = category.get("mode", "public")
        lines.append(f"{category['name']} [{category_mode}]")
        for channel in category.get("channels", []):
            mode = channel.get("mode", category_mode)
            lines.append(f"  {channel['name']} ({channel['kind']}, {mode})")
    return "\n".join(lines)
