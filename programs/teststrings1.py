assert "5" == "5"
assert not ("5" == "6")
assert "5" .__add__("6") == str.__add__("5", "6") == "5" + "6" == "56"
