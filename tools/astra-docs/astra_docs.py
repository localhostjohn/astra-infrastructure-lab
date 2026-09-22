#!/usr/bin/env python3
"""Astra read-only infrastructure documentation collector."""

from __future__ import annotations

import json
import re
import shutil
import subprocess
from datetime import datetime, timezone
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[2]
PUBLIC_OUTPUT = ROOT / "docs" / "generated"
PRIVATE_OUTPUT = ROOT / ".astra-docs" / "private"

IPV4_RE = re.compile(r"\b(?:\d{1,3}\.){3}\d{1,3}\b")
IPV6_RE = re.compile(r"(?<![0-9A-Fa-f:])(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}(?![0-9A-Fa-f:])")
MAC_RE = re.compile(r"\b(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b")
LONG_HEX_RE = re.compile(r"\b[0-9A-Fa-f]{12,64}\b")
ACCOUNT_RE = re.compile(r"\b[^\s@]+@(?=\s|$)")


def run(command: list[str]) -> dict[str, Any]:
    """Run a read-only command and capture its result without failing the scan."""
    executable = command[0]
    if shutil.which(executable) is None:
        return {"available": False, "command": " ".join(command), "output": ""}

    proc = subprocess.run(command, capture_output=True, text=True, check=False)
    return {
        "available": True,
        "command": " ".join(command),
        "returncode": proc.returncode,
        "output": proc.stdout.strip(),
        "error": proc.stderr.strip(),
    }


def collect() -> dict[str, Any]:
    commands = {
        "hostname": ["hostnamectl"],
        "os_release": ["cat", "/etc/os-release"],
        "interfaces": ["ip", "-brief", "address"],
        "routes": ["ip", "route"],
        "neighbours": ["ip", "neigh"],
        "storage": ["lsblk", "-o", "NAME,SIZE,FSTYPE,MOUNTPOINTS"],
        "filesystems": ["df", "-hT"],
        "docker_containers": ["docker", "ps", "--format", "{{json .}}"],
        "docker_networks": ["docker", "network", "ls"],
        "docker_volumes": ["docker", "volume", "ls"],
        "tailscale": ["tailscale", "status"],
    }

    return {
        "metadata": {
            "generated_utc": datetime.now(timezone.utc).isoformat(),
            "collector_version": "0.2.0",
            "mode": "read-only",
            "public_output": "sanitized",
        },
        "discovery": {name: run(cmd) for name, cmd in commands.items()},
    }


def sanitize_text(value: str) -> str:
    """Redact common infrastructure identifiers before public output."""
    value = MAC_RE.sub("<MAC_REDACTED>", value)
    value = IPV4_RE.sub("<IPV4_REDACTED>", value)
    value = IPV6_RE.sub("<IPV6_REDACTED>", value)
    value = LONG_HEX_RE.sub("<ID_REDACTED>", value)
    value = ACCOUNT_RE.sub("<ACCOUNT_REDACTED>", value)
    return value


def sanitize(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {key: sanitize(value) for key, value in obj.items()}
    if isinstance(obj, list):
        return [sanitize(value) for value in obj]
    if isinstance(obj, str):
        return sanitize_text(obj)
    return obj


def sanitize_tailscale(data: dict[str, Any]) -> None:
    """Remove Tailscale device and account names while retaining useful state."""
    item = data.get("discovery", {}).get("tailscale", {})
    output = item.get("output")
    if not isinstance(output, str):
        return

    safe_lines = []
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 3:
            fields[1] = "<DEVICE_REDACTED>"
            fields[2] = "<ACCOUNT_REDACTED>"
        safe_lines.append("  ".join(fields))
    item["output"] = "\n".join(safe_lines)


def section(title: str, item: dict[str, Any]) -> str:
    if not item.get("available", False):
        body = "Command unavailable on this host."
    elif item.get("returncode", 0) != 0:
        body = item.get("error") or "Command returned a non-zero exit code."
    else:
        body = item.get("output") or "(no output)"
    return f"## {title}\\n\\n```text\\n{body}\\n```\\n"


def render_runbook(data: dict[str, Any]) -> str:
    d = data["discovery"]
    generated = data["metadata"]["generated_utc"]
    parts = [
        "# Astra Infrastructure Runbook — Generated Public Snapshot\n",
        f"> Generated automatically at {generated}. Collector mode: **read-only**.\n",
        "This public snapshot is rendered only from sanitised discovery data. "
        "Raw discovery remains local in a Git-ignored private directory.\n",
        section("Host", d["hostname"]),
        section("Operating System", d["os_release"]),
        section("Network Interfaces", d["interfaces"]),
        section("Routing Table", d["routes"]),
        section("Network Neighbours", d["neighbours"]),
        section("Block Storage", d["storage"]),
        section("Filesystem Usage", d["filesystems"]),
        section("Docker Containers", d["docker_containers"]),
        section("Docker Networks", d["docker_networks"]),
        section("Docker Volumes", d["docker_volumes"]),
        section("Tailscale", d["tailscale"]),
        "## Operational Notes\n\n"
        "- This snapshot is evidence of observed state, not desired state.\n"
        "- Validate critical services after any infrastructure change.\n"
        "- Never commit the private raw inventory.\n"
        "- Review generated public artefacts before publishing.\n"
        "- Future milestones will add service dependencies, recovery procedures, Azure/AD discovery and diagrams.\n",
    ]
    return "\n".join(parts)


def main() -> None:
    PUBLIC_OUTPUT.mkdir(parents=True, exist_ok=True)
    PRIVATE_OUTPUT.mkdir(parents=True, exist_ok=True)

    inventory = collect()
    safe_inventory = sanitize(inventory)
    sanitize_tailscale(safe_inventory)

    (PRIVATE_OUTPUT / "inventory.json").write_text(
        json.dumps(inventory, indent=2), encoding="utf-8"
    )
    (PUBLIC_OUTPUT / "sanitized-inventory.json").write_text(
        json.dumps(safe_inventory, indent=2), encoding="utf-8"
    )
    (PUBLIC_OUTPUT / "astra-runbook.md").write_text(
        render_runbook(safe_inventory), encoding="utf-8"
    )

    legacy_raw = PUBLIC_OUTPUT / "inventory.json"
    if legacy_raw.exists():
        legacy_raw.unlink()

    print("Astra documentation collection complete.")
    print(f"Private raw inventory: {PRIVATE_OUTPUT / 'inventory.json'}")
    print(f"Public-safe output: {PUBLIC_OUTPUT}")
    print("Review generated public artefacts before committing them.")


if __name__ == "__main__":
    main()
