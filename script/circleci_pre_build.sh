#!/bin/bash
# Ensure exit codes other than 0 fail the build
set -e
# Check for asdf
if ! asdf | grep version; then
 git clone https://github.com/HashNuke/asdf.git ~/.asdf;
fi
# Add plugins for asdf
if ! asdf plugin-list | grep -q erlang; then
  asdf plugin-add erlang https://github.com/HashNuke/asdf-erlang.git
fi

if ! asdf plugin-list | grep -q elixir; then
  asdf plugin-add elixir https://github.com/HashNuke/asdf-elixir.git
fi

asdf install
