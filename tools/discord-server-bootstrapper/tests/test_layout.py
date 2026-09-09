import copy
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from layout import load_layout, validate_layout


class LayoutTests(unittest.TestCase):
    def setUp(self):
        self.data = load_layout()

    def test_default_layout_valid(self):
        self.assertTrue(validate_layout(self.data))

    def test_staff_roles_must_exist(self):
        data = copy.deepcopy(self.data)
        data["staff_roles"].append("Missing Role")
        with self.assertRaisesRegex(ValueError, "undefined roles"):
            validate_layout(data)

    def test_administrator_role_is_rejected(self):
        data = copy.deepcopy(self.data)
        data["roles"][0]["permissions"] = ["administrator"]
        with self.assertRaisesRegex(ValueError, "Administrator"):
            validate_layout(data)

    def test_private_category_cannot_have_public_child(self):
        data = copy.deepcopy(self.data)
        staff = next(c for c in data["categories"] if c["mode"] == "staff")
        staff["channels"][0]["mode"] = "public"
        with self.assertRaisesRegex(ValueError, "less restrictive"):
            validate_layout(data)


if __name__ == "__main__":
    unittest.main()
