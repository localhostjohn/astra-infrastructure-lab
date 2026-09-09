#!/usr/bin/env python3
"""Reusable, non-destructive Discord server bootstrapper driven by layout.json."""
import argparse
import asyncio
import os
import re
import sys
from pathlib import Path

from layout import ROOT, load_layout, preview

DEFAULT_REASON = "Authorised Discord server bootstrap"


def arguments():
    parser = argparse.ArgumentParser(description=__doc__)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--apply", action="store_true", help="Create missing resources in the configured server.")
    group.add_argument("--invite", action="store_true", help="Print an OAuth invite for your setup bot.")
    parser.add_argument("--layout", default=str(ROOT / "layout.json"), help="Path to a JSON server blueprint.")
    parser.add_argument("--set-icon", action="store_true", help="Set the configured icon only if the server has no icon.")
    parser.add_argument("--no-messages", action="store_true", help="Skip all starter messages.")
    return parser.parse_args()


def role_permissions(discord, definition):
    permissions = discord.Permissions.none()
    for name in definition.get("permissions", []):
        if name == "administrator":
            raise ValueError("Administrator permission is intentionally prohibited.")
        if not hasattr(permissions, name):
            raise ValueError(f"Unknown Discord permission: {name}")
        setattr(permissions, name, True)
    return permissions


def bot_permissions(discord, icon=False):
    names = (
        "view_channel", "send_messages", "read_message_history", "embed_links",
        "add_reactions", "connect", "speak", "manage_channels", "manage_roles",
        "manage_messages", "manage_threads", "kick_members", "moderate_members",
        "view_audit_log",
    )
    permissions = discord.Permissions.none()
    for name in names:
        setattr(permissions, name, True)
    if icon:
        permissions.manage_guild = True
    return permissions


def staff_role_names(data):
    return tuple(data.get("staff_roles", []))


def overwrites_for(discord, guild, me, role_map, mode, staff_roles):
    everyone = guild.default_role
    if mode == "public":
        return None

    overwrites = {}
    if mode == "read_only":
        overwrites[everyone] = discord.PermissionOverwrite(
            view_channel=True,
            read_message_history=True,
            send_messages=False,
            add_reactions=False,
            create_public_threads=False,
            create_private_threads=False,
        )
        for name in staff_roles:
            overwrites[role_map[name]] = discord.PermissionOverwrite(
                view_channel=True,
                read_message_history=True,
                send_messages=True,
                manage_messages=True,
                manage_threads=True,
                add_reactions=True,
            )
    else:
        overwrites[everyone] = discord.PermissionOverwrite(view_channel=False)
        if mode == "staff":
            for name in staff_roles:
                overwrites[role_map[name]] = discord.PermissionOverwrite(
                    view_channel=True,
                    read_message_history=True,
                    send_messages=True,
                    connect=True,
                    speak=True,
                )
        elif mode != "owner":
            raise ValueError(f"Unsupported private mode: {mode}")

    overwrites[me] = discord.PermissionOverwrite(
        view_channel=True,
        read_message_history=True,
        send_messages=True,
        embed_links=True,
        connect=True,
        speak=True,
    )
    return overwrites


def private_is_safe(channel, guild, me, role_map, mode, staff_roles):
    if mode not in {"owner", "staff"}:
        return True
    overwrites = channel.overwrites
    everyone = overwrites.get(guild.default_role)
    if everyone is None or everyone.view_channel is not False:
        return False
    allowed = {me.id, guild.owner_id}
    if mode == "staff":
        allowed.update(role_map[name].id for name in staff_roles)
    for target, overwrite in overwrites.items():
        if overwrite.view_channel is True and target.id not in allowed:
            return False
    return True


def locate_existing(channels, name, kind, parent_id=None):
    matches = [ch for ch in channels if ch.name == name]
    if len(matches) > 1:
        raise RuntimeError(f"Multiple existing channels/categories named {name!r}. Resolve the ambiguity manually.")
    if not matches:
        return None
    found = matches[0]
    if found.type != kind:
        raise RuntimeError(f"{name!r} already exists with a different channel type. Nothing will be moved or replaced.")
    if parent_id is not None and found.category_id != parent_id:
        raise RuntimeError(f"{name!r} exists outside the intended category. Move it manually or choose a fresh server.")
    return found


async def refresh_snapshot(guild):
    return list(await guild.fetch_roles()), list(await guild.fetch_channels())


async def ensure_roles(discord, guild, roles, definitions, reason):
    result = {}
    for definition in definitions:
        name = definition["name"]
        matches = [r for r in roles if r.name == name]
        if len(matches) > 1:
            raise RuntimeError(f"Duplicate existing role name: {name!r}. Resolve it before continuing.")
        if matches:
            role = matches[0]
            print(f"[SKIP] Existing role: {name}")
        else:
            role = await guild.create_role(
                name=name,
                permissions=role_permissions(discord, definition),
                colour=discord.Colour(int(definition.get("colour", "#99AAB5").lstrip("#"), 16)),
                hoist=definition.get("hoist", False),
                mentionable=definition.get("mentionable", False),
                reason=reason,
            )
            roles.append(role)
            print(f"[CREATE] Role: {name}")
        result[name] = role
    return result


async def ensure_category(discord, guild, channels, definition, me, role_map, staff_roles, reason):
    name = definition["name"]
    mode = definition.get("mode", "public")
    category = locate_existing(channels, name, discord.ChannelType.category)
    if category:
        if not private_is_safe(category, guild, me, role_map, mode, staff_roles):
            raise RuntimeError(f"Existing private category {name!r} has unexpected permissions. Refusing to reuse it.")
        print(f"[SKIP] Existing category: {name}")
        return category

    overwrites = overwrites_for(discord, guild, me, role_map, mode, staff_roles)
    kwargs = {"reason": reason}
    if overwrites is not None:
        kwargs["overwrites"] = overwrites
    category = await guild.create_category(name, **kwargs)
    channels.append(category)
    print(f"[CREATE] Category: {name}")
    return category


async def ensure_channel(discord, guild, channels, category, definition, me, role_map, inherited_mode, staff_roles, reason):
    name = definition["name"]
    mode = definition.get("mode", inherited_mode)
    kind = discord.ChannelType.voice if definition["kind"] == "voice" else discord.ChannelType.text
    channel = locate_existing(channels, name, kind, category.id)
    if channel:
        if mode in {"owner", "staff"} and not private_is_safe(channel, guild, me, role_map, mode, staff_roles):
            raise RuntimeError(f"Existing private channel {name!r} has unexpected permissions. Refusing to reuse it.")
        print(f"[SKIP] Existing channel: {name}")
        return channel

    overwrites = overwrites_for(discord, guild, me, role_map, mode, staff_roles)
    if overwrites is None and inherited_mode in {"owner", "staff"}:
        raise RuntimeError("A private category cannot contain a public child.")
    kwargs = {"category": category, "reason": reason}
    if overwrites is not None:
        kwargs["overwrites"] = overwrites
    if kind == discord.ChannelType.voice:
        channel = await guild.create_voice_channel(name, **kwargs)
    else:
        channel = await guild.create_text_channel(name, topic=definition.get("topic", ""), **kwargs)
    channels.append(channel)
    print(f"[CREATE] Channel: {name}")
    return channel


def render_message(content, channel_map):
    def replace(match):
        name = match.group(1)
        if name not in channel_map:
            raise ValueError(f"Unknown channel reference: {name}")
        return channel_map[name].mention
    return re.sub(r"\{channel:([^}]+)\}", replace, content)


async def post_starter(discord, channel, me, key, content, marker_prefix):
    marker = f"{marker_prefix} · {key}"
    async for message in channel.history(limit=100):
        if message.author.id == me.id and any(embed.footer.text == marker for embed in message.embeds):
            print(f"[SKIP] Starter message: {channel.name}")
            return
    embed = discord.Embed(description=content, colour=discord.Colour(0x5865F2))
    embed.set_footer(text=marker)
    await channel.send(embed=embed, allowed_mentions=discord.AllowedMentions.none())
    print(f"[POST] Starter message: {channel.name}")


async def apply_layout(discord, guild, data, me, no_messages=False, set_icon=False):
    permissions = me.guild_permissions
    required = (
        "manage_roles", "manage_channels", "view_channel", "send_messages",
        "read_message_history", "embed_links", "add_reactions", "connect", "speak",
        "manage_messages", "manage_threads", "kick_members", "moderate_members", "view_audit_log",
    )
    missing = [name for name in required if not getattr(permissions, name)]
    if set_icon and not permissions.manage_guild:
        missing.append("manage_guild (needed only for --set-icon)")
    if missing:
        raise RuntimeError("Setup bot is missing permissions: " + ", ".join(missing))

    roles, channels = await refresh_snapshot(guild)
    existing_roles = {r.name: r for r in roles}
    staff_roles = staff_role_names(data)

    for category_def in data.get("categories", []):
        category_mode = category_def.get("mode", "public")
        existing_category = locate_existing(channels, category_def["name"], discord.ChannelType.category)
        if existing_category and category_mode in {"owner", "staff"}:
            if category_mode == "staff" and any(name not in existing_roles for name in staff_roles):
                raise RuntimeError("An existing staff category needs its configured staff roles for safe validation.")
            if not private_is_safe(existing_category, guild, me, existing_roles, category_mode, staff_roles):
                raise RuntimeError(f"Unsafe existing private category: {category_def['name']}. No changes made.")
        if existing_category:
            for channel_def in category_def.get("channels", []):
                mode = channel_def.get("mode", category_mode)
                kind = discord.ChannelType.voice if channel_def["kind"] == "voice" else discord.ChannelType.text
                existing_channel = locate_existing(channels, channel_def["name"], kind, existing_category.id)
                if existing_channel and mode in {"owner", "staff"}:
                    if mode == "staff" and any(name not in existing_roles for name in staff_roles):
                        raise RuntimeError("An existing staff channel needs its configured staff roles for safe validation.")
                    if not private_is_safe(existing_channel, guild, me, existing_roles, mode, staff_roles):
                        raise RuntimeError(f"Unsafe existing private channel: {channel_def['name']}. No changes made.")

    role_map = await ensure_roles(discord, guild, roles, data.get("roles", []), data.get("audit_reason", DEFAULT_REASON))
    channel_map = {}
    reason = data.get("audit_reason", DEFAULT_REASON)
    for category_def in data.get("categories", []):
        mode = category_def.get("mode", "public")
        category = await ensure_category(discord, guild, channels, category_def, me, role_map, staff_roles, reason)
        for channel_def in category_def.get("channels", []):
            channel = await ensure_channel(
                discord, guild, channels, category, channel_def, me, role_map, mode, staff_roles, reason
            )
            channel_map[channel_def["name"]] = channel

    if not no_messages:
        marker_prefix = data.get("message_marker", f"{data['server_name']} Setup")
        for name, content in data.get("starter_messages", {}).items():
            channel = channel_map[name]
            await post_starter(discord, channel, me, name, render_message(content, channel_map), marker_prefix)

    if set_icon:
        icon_path_value = data.get("icon_path", "branding/server-icon.png")
        icon_path = (ROOT / icon_path_value).resolve()
        if guild.icon is not None:
            print("[SKIP] Server already has an icon. Existing branding is preserved.")
        elif not icon_path.exists():
            print(f"[SKIP] Icon file not found: {icon_path_value}")
        else:
            await guild.edit(icon=icon_path.read_bytes(), reason=reason)
            print("[SET] Server icon.")

    print("\nServer setup complete. Review roles, channel permissions and bot hierarchy in Discord.")


async def connect_and_apply(discord, token, guild_id, data, args):
    intents = discord.Intents.none()
    intents.guilds = True
    client = discord.Client(intents=intents)

    @client.event
    async def on_ready():
        if getattr(client, "_bootstrap_running", False):
            return
        client._bootstrap_running = True
        try:
            guild = client.get_guild(guild_id)
            if guild is None:
                raise RuntimeError("The bot is not in the configured server. Check GUILD_ID and the invite.")
            me = guild.get_member(client.user.id) or await guild.fetch_member(client.user.id)
            print(f"Connected as {client.user} to {guild.name} ({guild.id}).")
            if guild.name != data["server_name"]:
                print(f"Note: blueprint is named {data['server_name']!r}; existing server is {guild.name!r}. It will not be renamed.")
            await apply_layout(discord, guild, data, me, args.no_messages, args.set_icon)
        except Exception as exc:
            client._bootstrap_error = exc
            print(f"\nERROR: {exc}", file=sys.stderr)
        finally:
            await client.close()

    async with client:
        await client.start(token)
    if getattr(client, "_bootstrap_error", None):
        raise client._bootstrap_error


def main():
    args = arguments()
    layout_path = Path(args.layout).expanduser().resolve()
    data = load_layout(layout_path)
    print(preview(data))
    if not args.apply and not args.invite:
        print("\nPreview only. No Discord API calls have been made.")
        return

    try:
        import discord
        from dotenv import load_dotenv
    except ImportError:
        raise SystemExit("Install dependencies first: python -m pip install -r requirements.txt")

    load_dotenv(ROOT / ".env")
    if args.invite:
        client_id = os.getenv("DISCORD_CLIENT_ID", "").strip()
        if not client_id.isdecimal():
            raise SystemExit("Set DISCORD_CLIENT_ID in your local .env file first.")
        print("\nSetup bot invite:\n")
        print(discord.utils.oauth_url(int(client_id), permissions=bot_permissions(discord, args.set_icon), scopes=("bot",)))
        return

    token = os.getenv("DISCORD_TOKEN", "").strip()
    guild_id = os.getenv("GUILD_ID", "").strip()
    if not token or not guild_id.isdecimal():
        raise SystemExit("Set DISCORD_TOKEN and GUILD_ID in your local .env file. Never share the token.")

    print(f"\nThis will create missing resources from {layout_path.name} in server ID {guild_id}.")
    print("Existing matching resources will not be deleted, moved, renamed or have permissions replaced.")
    confirmation = input(f"Type APPLY {guild_id} to continue: ").strip()
    if confirmation != f"APPLY {guild_id}":
        raise SystemExit("Cancelled. No Discord changes made.")

    try:
        asyncio.run(connect_and_apply(discord, token, int(guild_id), data, args))
    except Exception as exc:
        raise SystemExit(f"Setup stopped: {exc}") from None


if __name__ == "__main__":
    main()
