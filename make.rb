require 'getdb'
db = getdb('musicthoughts')

# langs = array of 2-char strings: en, es, fr, etc.
ok, langs = db.call('languages')

langs.each do |lang|
	site = 'site/%s/' % lang
	# make subdirectories, if they don't exist
	%w(t author contributor).each do |subdir|
		Dir.mkdir(site + subdir) unless File.directory?(site + subdir)
	end

	# get all approved thoughts & random thoughts.  write json
	ok, approved_thoughts = db.call('approved_thoughts', lang)
	File.open(site + 'thoughts.json', 'w') {|f| f.puts approved_thoughts.to_json }
	ok, random_thoughts = db.call('random_thoughts', lang)
	File.open(site + 'random.json', 'w') {|f| f.puts random_thoughts.to_json }

	# write home
	# write approved thought pages
	# write author pages
	# write contributor pages
end
