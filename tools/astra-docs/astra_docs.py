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
OUTPUT = ROOT / "docs" / "generated"


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
            "collector_version": "0.1.0",
            "mode": "read-only",
        },
        "discovery": {name: run(cmd) for name, cmd in commands.items()},
    }


def sanitize_text(value: str) -> str:
    # IPv4 addresses
    value = re.sub(r"\b(?:\d{1,3}\.){3}\d{1,3}\b", "<IPV4_REDACTED>", value)
    # Common MAC address format
    value = re.sub(r"\b(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b", "<MAC_REDACTED>", value)
    # Tailscale 100.x addresses are already covered by IPv4 redaction.
    return value


def sanitize(obj: Any) -> Any:
    if isinstance(obj, dict):
        return {key: sanitize(value) for key, value in obj.items()}
    if isinstance(obj, list):
        return [sanitize(value) for value in obj]
    if isinstance(obj, str):
        return sanitize_text(obj)
    return obj


def section(title: str, item: dict[str, Any]) -> str:
    if not item.get("available", False):
        body = "Command unavailable on this host."
    elif item.get("returncode", 0) != 0:
        body = item.get("error") or "Command returned a non-zero exit code."
    else:
        body = item.get("output") or "(no output)"
    return f"## {title}\n\n```text\n{body}\n```\n"


def render_runbook(data: dict[str, Any]) -> str:
    d = data["discovery"]
    generated = data["metadata"]["generated_utc"]
    parts = [
        "# Astra Infrastructure Runbook — Generated Snapshot\n",
        f"> Generated automatically at {generated}. Collector mode: **read-only**.\n",
        "This document is generated from live discovery on the host. "
        "Review before publishing because the unsanitised version may contain internal addressing.\n",
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
        "- Do not commit credentials, tokens, private keys, or other secrets.\n"
        "- Future milestones will add service dependencies, recovery procedures, Azure/AD discovery and diagrams.\n",
    ]
    return "\n".join(parts)


def main() -> None:
    OUTPUT.mkdir(parents=True, exist_ok=True)
    inventory = collect()
    safe_inventory = sanitize(inventory)

    (OUTPUT / "inventory.json").write_text(
        json.dumps(inventory, indent=2), encoding="utf-8"
    )
    (OUTPUT / "sanitized-inventory.json").write_text(
        json.dumps(safe_inventory, indent=2), encoding="utf-8"
    )
    (OUTPUT / "astra-runbook.md").write_text(
        render_runbook(inventory), encoding="utf-8"
    )

    print("Astra documentation collection complete.")
    print(f"Output: {OUTPUT}")
    print("Review raw output before committing it to a public repository.")


if __name__ == "__main__":
    main()
