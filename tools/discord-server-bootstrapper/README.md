# Discord Server Bootstrapper

A reusable Python tool for creating a Discord server structure from a JSON blueprint. It can create roles, categories, text/voice channels, private staff or owner areas, and starter messages without deleting or moving existing resources.

This tool is intentionally **non-destructive** and does **not** request Discord Administrator permission.

## Features

- JSON-driven server templates
- Preview mode before any Discord API call
- Idempotent reruns: existing matching resources are skipped
- Public, read-only, staff-only and owner-only permission modes
- Starter messages with `{channel:name}` references converted to real channel mentions
- Optional server icon support
- OAuth invite generation with the required bot permissions
- Confirmation prompt before modifying a server
- `.env` secrets kept out of Git by default

## Requirements

- Python 3.10+
- A Discord application/bot created in the Discord Developer Portal
- Permission to add that bot to the target server

## Quick start on Windows

```powershell
py -3 -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
Copy-Item .env.example .env
```

Edit `.env` locally:

```dotenv
DISCORD_CLIENT_ID=YOUR_APPLICATION_ID
DISCORD_TOKEN=YOUR_BOT_TOKEN
GUILD_ID=YOUR_SERVER_ID
```

Never commit `.env` or share a bot token.

### 1. Edit the server blueprint

Edit `layout.json`. The included file is deliberately generic and is safe to use as a starting point for a new server.

Supported modes:

- `public` — normal public channel/category
- `read_only` — everyone can read; configured staff roles can post
- `staff` — only configured staff roles, the server owner and setup bot can access
- `owner` — only the server owner and setup bot can access

`staff_roles` must contain role names that also exist in the `roles` array.

### 2. Preview

```powershell
.\.venv\Scripts\python.exe setup.py
```

Preview mode does not connect to Discord.

You can also keep several templates and select one explicitly:

```powershell
.\.venv\Scripts\python.exe setup.py --layout .\templates\my-community.json
```

### 3. Generate the bot invite

```powershell
.\.venv\Scripts\python.exe setup.py --invite
```

Open the generated OAuth URL, choose the target server, and authorise the bot.

### 4. Apply the blueprint

```powershell
.\.venv\Scripts\python.exe setup.py --apply
```

The tool requires an explicit `APPLY <server-id>` confirmation before making changes.

Useful options:

```powershell
# Do not post starter messages
.\.venv\Scripts\python.exe setup.py --apply --no-messages

# Use another layout file
.\.venv\Scripts\python.exe setup.py --apply --layout .\templates\another-server.json

# Request Manage Server in the invite and set branding/server-icon.png if the server has no icon
.\.venv\Scripts\python.exe setup.py --invite --set-icon
.\.venv\Scripts\python.exe setup.py --apply --set-icon
```

## Blueprint example

```json
{
  "server_name": "Example Community",
  "staff_roles": ["Admin", "Moderator"],
  "roles": [
    {"name": "Admin", "permissions": ["manage_messages", "moderate_members"]},
    {"name": "Moderator", "permissions": ["manage_messages"]}
  ],
  "categories": [
    {
      "name": "COMMUNITY",
      "mode": "public",
      "channels": [
        {"name": "general", "kind": "text", "topic": "General discussion."}
      ]
    }
  ],
  "starter_messages": {
    "general": "Welcome to the server."
  }
}
```

## Safety design

The bootstrapper does not automatically delete, rename, move or overwrite matching existing resources. It also rejects `administrator` in role definitions. If an existing private category/channel has unexpected visibility, the script stops instead of reusing it.

The setup bot still needs powerful temporary permissions such as Manage Channels and Manage Roles. Keep its role below your own trusted owner/admin role and remove the bot when you no longer need it.

## Reusing it for another server

1. Create the new Discord server.
2. Create or reuse a setup bot application.
3. Copy this project into a new working directory.
4. Create a local `.env` with the new server ID and bot token.
5. Edit or replace `layout.json`.
6. Preview with `setup.py`.
7. Generate the invite and add the bot.
8. Run `setup.py --apply`.
9. Review role hierarchy and private-channel permissions in Discord.

## Project structure

```text
.
├── README.md
├── setup.py
├── layout.py
├── layout.json
├── setup-windows.bat
├── requirements.txt
├── .env.example
├── .gitignore
└── tests/
    ├── test_layout.py
    └── test_setup.py
```

## Licence

Use and adapt this tool for your own Discord communities. Add a formal open-source licence before redistributing it as a public project if you want explicit reuse terms for third parties.
