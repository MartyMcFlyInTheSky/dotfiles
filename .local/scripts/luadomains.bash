#!/bin/bash

LUA_FILE="${1:-$HOME/.config/wezterm/ssh_domains.lua}"

lua - "$LUA_FILE" <<'EOF'
local file = arg[1]
local f = assert(loadfile(file))
local M = f()

for i, domain in ipairs(M.ssh_domains or {}) do
  print(domain.name)
end
EOF

