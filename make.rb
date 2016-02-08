require 'getdb'
db = getdb('musicthoughts')

# langs = array of 2-char strings: en, es, fr, etc.
ok, langs = db.call('languages')
