.PHONY: lint

lint:
	@command -v luacheck >/dev/null 2>&1 || { echo "Install luacheck: luarocks install luacheck"; exit 1; }
	luacheck WoWForeverRFT