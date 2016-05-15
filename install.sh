#!/bin/bash
prefs=
sublime=
backup=

for dir in $HOME/Library/Application\ Support/Sublime\ Text\ {2,3}/Packages; do 
  [[ -d "$dir" ]] && sublime=$dir
done

[[ -z $sublime ]] && { echo "Sublime Text directory not found"; exit 1; }

pushd $(dirname "$0") > /dev/null
prefs="$PWD"
backup="${prefs}/backup"
user=${sublime}/User
popd > /dev/null

for dir in "$user" "$backup"; do 
  mkdir -p "$dir" 
done

while IFS='' read -r line || [[ -n "$line" ]]; do 

  path=$(echo "$line" | sed 's/^Files \(.*\) and.*$/\1/;s/^Only in \(.*\): \(.*\)$/\1\/\2/')
  
  # Ignore paths containing or starting with a dot (.):
  ignore='\.git \.cache \.pyc \.last-run \.log -ca-bundle'
  [[ $path =~ ${ignore// /|} \
  || $(basename "$path") =~ ^\.\
  || -z $path ]] && continue

  # Back up the unique file
  cp -r "$path" "$backup/${path#*$user/}"

done <<< "$(diff -qr "$user" "$prefs" | grep "$user")"

# Trash original '/User' file
rm -rf "$user"

# Create the symlink
ln -s "$prefs/" "$user"

# Update the icon
find /Applications/Sublime*/Contents/Resources \
  -maxdepth 1 \
  -type f \
  -name "Sublime*.icns" \
  -exec sh -c '
  app="${0%%.app*}.app"
  cp "$1/icon/icon.icns" "$0"
  cp -r "$app" "$app.copy"
  rm -rf "$app"
  mv "$app.copy" "$app"
  echo "Icon updated for $app"
' "{}" "$prefs" \;



