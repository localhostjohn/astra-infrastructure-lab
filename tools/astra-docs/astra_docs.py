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
IPV6_RE = re.compile(
    r"(?<![0-9A-Fa-f:])(?=[0-9A-Fa-f:]*[A-Fa-f])(?:[0-9A-Fa-f]{0,4}:){2,7}[0-9A-Fa-f]{0,4}(?![0-9A-Fa-f:])"
)
MAC_RE = re.compile(r"\b(?:[0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}\b")
LONG_HEX_RE = re.compile(r"\b[0-9A-Fa-f]{12,64}\b")
ACCOUNT_RE = re.compile(r"\b[^\s@]+@(?=\s|$)")


def run(command: list[str]) -> dict[str, Any]:
    """Run a read-only command and capture its result without failing the scan."""
    if shutil.which(command[0]) is None:
        return {"available": False, "command": " ".join(command), "output": ""}

    proc = subprocess.run(command, capture_output=True, text=True, check=False)
    return {
        "available": True,
        "command": " ".join(command),
        "returncode": proc.returncode,
        "output": proc.stdout.strip(),
        "error": proc.stderr.strip(),
    }


def collect_docker_containers() -> dict[str, Any]:
    """Collect only operational Docker fields useful to public documentation."""
    result = run([
        "docker", "ps", "--format",
        "{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.Networks}}",
    ])
    if not result.get("available") or result.get("returncode", 0) != 0:
        return result

    containers = []
    for line in result.get("output", "").splitlines():
        fields = line.split("\t")
        fields += [""] * (5 - len(fields))
        containers.append({
            "name": fields[0],
            "image": fields[1],
            "status": fields[2],
            "ports": fields[3],
            "networks": [n for n in fields[4].split(",") if n],
        })

    return {
        "available": True,
        "returncode": 0,
        "containers": containers,
        "error": result.get("error", ""),
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
        "docker_networks": ["docker", "network", "ls", "--format", "{{.Name}}\t{{.Driver}}\t{{.Scope}}"],
        "docker_volumes": ["docker", "volume", "ls", "--format", "{{.Name}}\t{{.Driver}}"],
        "tailscale": ["tailscale", "status"],
    }
    discovery = {name: run(cmd) for name, cmd in commands.items()}
    discovery["docker_containers"] = collect_docker_containers()

    return {
        "metadata": {
            "generated_utc": datetime.now(timezone.utc).isoformat(),
            "collector_version": "0.3.0",
            "mode": "read-only",
            "public_output": "sanitized",
        },
        "discovery": discovery,
    }


def sanitize_text(value: str) -> str:
    """Redact common infrastructure identifiers before public output."""
    value = MAC_RE.sub("<MAC_REDACTED>", value)
    value = IPV4_RE.sub("<IPV4_REDACTED>", value)
    value = IPV6_RE.sub("<IPV6_REDACTED>", value)
    value = LONG_HEX_RE.sub("<ID_REDACTED>", value)
    value = ACCOUNT_RE.sub("<ACCOUNT_REDACTED>", value)
    return value


def validate_sanitizer() -> None:
    """Fail safely if core redaction behaviour regresses."""
    timestamp = "2026-09-22T22:00:31.388283+00:00"
    if sanitize_text(timestamp) != timestamp:
        raise RuntimeError("Sanitizer regression: ISO timestamp was altered.")
    if "<IPV6_REDACTED>" not in sanitize_text("peer fd7a:115c:a1e0::1 active"):
        raise RuntimeError("Sanitizer regression: IPv6 address was not redacted.")


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


def command_section(title: str, item: dict[str, Any]) -> str:
    if not item.get("available", False):
        body = "Command unavailable on this host."
    elif item.get("returncode", 0) != 0:
        body = item.get("error") or "Command returned a non-zero exit code."
    else:
        body = item.get("output") or "(no output)"
    return f"## {title}\n\n```text\n{body}\n```\n"


def docker_table(item: dict[str, Any]) -> str:
    containers = item.get("containers", [])
    if not containers:
        return "## Docker Containers\n\nNo running containers were discovered.\n"
    lines = [
        "## Docker Containers",
        "",
        "| Container | Image | Status | Networks | Ports |",
        "| --- | --- | --- | --- | --- |",
    ]
    for c in containers:
        networks = ", ".join(c.get("networks", [])) or "—"
        ports = c.get("ports") or "—"
        lines.append(
            f"| {c.get('name','')} | {c.get('image','')} | {c.get('status','')} | {networks} | {ports} |"
        )
    return "\n".join(lines) + "\n"


def render_topology(data: dict[str, Any]) -> str:
    containers = data["discovery"]["docker_containers"].get("containers", [])
    lines = [
        "# Astra Raspberry Pi — Generated Topology",
        "",
        "> Generated from the sanitised v0.3 discovery model. Connections shown are Docker network memberships observed by the collector.",
        "",
        "```mermaid",
        "flowchart LR",
        '    LAN["LAN / Ethernet"] --> PI["astra-pi"]',
        '    TS["Tailscale"] --> PI',
    ]
    networks: dict[str, list[str]] = {}
    for c in containers:
        for network in c.get("networks", []):
            networks.setdefault(network, []).append(c.get("name", "container"))

    for index, (network, members) in enumerate(sorted(networks.items()), start=1):
        net_id = f"N{index}"
        lines.append(f'    PI --> {net_id}["Docker: {network}"]')
        for member_index, member in enumerate(sorted(members), start=1):
            node_id = f"{net_id}C{member_index}"
            safe_label = member.replace('"', "'")
            lines.append(f'    {net_id} --> {node_id}["{safe_label}"]')

    lines.extend(["```", "", "Only observed Docker network membership is represented; application-level dependencies are not inferred.", ""])
    return "\n".join(lines)


def render_runbook(data: dict[str, Any]) -> str:
    d = data["discovery"]
    generated = data["metadata"]["generated_utc"]
    parts = [
        "# Astra Infrastructure Runbook — Generated Public Snapshot\n",
        f"> Generated automatically at {generated}. Collector mode: **read-only**.\n",
        "This public snapshot is rendered only from sanitised discovery data. Raw discovery remains local in a Git-ignored private directory.\n",
        command_section("Host", d["hostname"]),
        command_section("Operating System", d["os_release"]),
        command_section("Network Interfaces", d["interfaces"]),
        command_section("Routing Table", d["routes"]),
        command_section("Network Neighbours", d["neighbours"]),
        command_section("Block Storage", d["storage"]),
        command_section("Filesystem Usage", d["filesystems"]),
        docker_table(d["docker_containers"]),
        command_section("Docker Networks", d["docker_networks"]),
        command_section("Docker Volumes", d["docker_volumes"]),
        command_section("Tailscale", d["tailscale"]),
        "## Operational Notes\n\n"
        "- This snapshot is evidence of observed state, not desired state.\n"
        "- Validate critical services after any infrastructure change.\n"
        "- Never commit the private raw inventory.\n"
        "- Review generated public artefacts before publishing.\n"
        "- The topology represents observed Docker network membership only.\n"
        "- Future milestones will add service dependencies, recovery procedures, Azure/AD discovery and desired-state comparison.\n",
    ]
    return "\n".join(parts)


def main() -> None:
    PUBLIC_OUTPUT.mkdir(parents=True, exist_ok=True)
    PRIVATE_OUTPUT.mkdir(parents=True, exist_ok=True)

    inventory = collect()
    safe_inventory = sanitize(inventory)
    sanitize_tailscale(safe_inventory)

    (PRIVATE_OUTPUT / "inventory.json").write_text(json.dumps(inventory, indent=2), encoding="utf-8")
    (PUBLIC_OUTPUT / "sanitized-inventory.json").write_text(json.dumps(safe_inventory, indent=2), encoding="utf-8")
    (PUBLIC_OUTPUT / "astra-runbook.md").write_text(render_runbook(safe_inventory), encoding="utf-8")
    (PUBLIC_OUTPUT / "astra-topology.md").write_text(render_topology(safe_inventory), encoding="utf-8")

    legacy_raw = PUBLIC_OUTPUT / "inventory.json"
    if legacy_raw.exists():
        legacy_raw.unlink()

    print("Astra documentation collection complete.")
    print(f"Collector version: {inventory['metadata']['collector_version']}")
    print(f"Private raw inventory: {PRIVATE_OUTPUT / 'inventory.json'}")
    print(f"Public-safe output: {PUBLIC_OUTPUT}")
    print("Review generated public artefacts before committing them.")


if __name__ == "__main__":
    main()
