import asyncio
import sys
import unittest
from pathlib import Path
from types import SimpleNamespace

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
import setup as app
from layout import load_layout


class Permissions:
    def __init__(self, **kwargs):
        object.__setattr__(self, "values", kwargs)
    @classmethod
    def none(cls):
        return cls()
    def __getattr__(self, name):
        if name in {"values"}:
            return object.__getattribute__(self, name)
        return self.values.get(name, False)
    def __setattr__(self, name, value):
        self.values[name] = value


class FullPermissions:
    def __getattr__(self, name):
        return True


class Overwrite:
    def __init__(self, **kwargs):
        self.values = kwargs
    def __getattr__(self, name):
        return self.values.get(name)


class Role:
    def __init__(self, id, name, permissions=None):
        self.id, self.name, self.permissions = id, name, permissions
    def __hash__(self):
        return hash(self.id)
    def __eq__(self, other):
        return getattr(other, "id", None) == self.id


class Embed:
    def __init__(self, description=None, colour=None):
        self.description = description
        self.footer = SimpleNamespace(text=None)
    def set_footer(self, *, text):
        self.footer.text = text


class FakeDiscord:
    Permissions = Permissions
    PermissionOverwrite = Overwrite
    Colour = staticmethod(lambda value: value)
    Embed = Embed
    AllowedMentions = SimpleNamespace(none=lambda: None)
    ChannelType = SimpleNamespace(category="category", text="text", voice="voice")


class Channel:
    def __init__(self, guild, name, kind, category=None, overwrites=None):
        self.guild = guild
        self.id = guild.next_id()
        self.name, self.type = name, kind
        self.category_id = category.id if category else None
        self.overwrites = overwrites or {}
        self.messages = []
        self.mention = f"<#{self.id}>"
    async def history(self, limit=100):
        for message in reversed(self.messages[-limit:]):
            yield message
    async def send(self, *, embed, allowed_mentions):
        self.messages.append(SimpleNamespace(author=self.guild.me, embeds=[embed]))


class Guild:
    def __init__(self):
        self._id = 100
        self.owner_id = 1
        self.default_role = Role(2, "@everyone")
        self.me = Role(3, "Setup Bot")
        self.me.guild_permissions = FullPermissions()
        self.roles = [self.default_role, self.me]
        self.channels = []
        self.icon = None
        self.created = 0
    def next_id(self):
        self._id += 1
        return self._id
    async def fetch_roles(self):
        return list(self.roles)
    async def fetch_channels(self):
        return list(self.channels)
    async def create_role(self, **kwargs):
        role = Role(self.next_id(), kwargs["name"], kwargs["permissions"])
        self.roles.append(role)
        self.created += 1
        return role
    async def create_category(self, name, **kwargs):
        return self.make_channel(name, "category", **kwargs)
    async def create_text_channel(self, name, **kwargs):
        return self.make_channel(name, "text", **kwargs)
    async def create_voice_channel(self, name, **kwargs):
        return self.make_channel(name, "voice", **kwargs)
    def make_channel(self, name, kind, **kwargs):
        if "overwrites" in kwargs and kwargs["overwrites"] is None:
            raise TypeError("overwrites parameter expects a dict")
        channel = Channel(self, name, kind, kwargs.get("category"), kwargs.get("overwrites"))
        self.channels.append(channel)
        self.created += 1
        return channel
    async def edit(self, **kwargs):
        pass


class SetupTests(unittest.TestCase):
    def setUp(self):
        self.guild = Guild()
        self.data = load_layout()

    def apply(self, **kwargs):
        return asyncio.run(app.apply_layout(FakeDiscord, self.guild, self.data, self.guild.me, **kwargs))

    def test_bot_permissions_have_no_administrator(self):
        p = app.bot_permissions(FakeDiscord)
        self.assertFalse(p.administrator)
        self.assertTrue(p.manage_roles)
        self.assertTrue(p.moderate_members)

    def test_fresh_setup_and_rerun(self):
        self.apply()
        expected_roles = 2 + len(self.data["roles"])
        expected_channels = len(self.data["categories"]) + sum(len(c["channels"]) for c in self.data["categories"])
        self.assertEqual(len(self.guild.roles), expected_roles)
        self.assertEqual(len(self.guild.channels), expected_channels)
        self.assertEqual(sum(len(c.messages) for c in self.guild.channels), len(self.data["starter_messages"]))
        count = self.guild.created
        self.apply()
        self.assertEqual(self.guild.created, count)
        self.assertEqual(sum(len(c.messages) for c in self.guild.channels), len(self.data["starter_messages"]))

    def test_public_creation_omits_none_overwrites(self):
        self.apply(no_messages=True)
        community = next(c for c in self.guild.channels if c.name == "COMMUNITY")
        self.assertEqual(community.overwrites, {})

    def test_owner_area_is_private(self):
        self.apply(no_messages=True)
        ops = next(c for c in self.guild.channels if c.name == "OWNER OPS")
        self.assertIs(ops.overwrites[self.guild.default_role].view_channel, False)


if __name__ == "__main__":
    unittest.main()
