#!/usr/bin/env zsh

echo "Shortening '$1'..."
TINYURL=$(curl -s "http://tinyurl.com/api-create.php?url=$1")
echo "Created link \"$TINYURL\""
echo $TINYURL | pbcopy
