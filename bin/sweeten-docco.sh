#!/bin/bash

# sweeten-docco.sh
# Sweeten docco output with basic support for Codo tags.

if [[ -e 'docs' ]]; then
  cd docs

  echo -n "Sweetening docco... "

  # Wrap doc tags
  sed -i -r 's/(@(api|param|return|see)[^<]*)/<div class="doc-tag"> \1 <\/div>/' *.html

  # Wrap param names in <code> tags, param types in <i> (listing names first),
  # and tag directives in <b> (after removing the '@').
  sed -i -r 's/(@param)\s+(\[.+\])\s+((,\s+|\S)+)/\1 <code>\3<\/code> \2/' *.html
  sed -i -r 's/(@param|@return)([^\[]+)\[(.+)\]/\1\2 <i>\3<\/i>/' *.html
  sed -i -r 's/@(api|param|return|see)/<b>\1<\/b>/' *.html

  # Append doc-tag style to docco's css
  echo '.doc-tag { color: #777; }' >> docco.css
  echo '.doc-tag * { color: #222; }' >> docco.css

  echo "Done."
else
  echo "Directory 'docs' not found."
fi
