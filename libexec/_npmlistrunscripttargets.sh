#!/bin/sh
cat package.json |\
  jq -r '.scripts | keys' |\
  tr '[],"' '    '
