require 'erb'
require 'getdb'
db = getdb('musicthoughts')

def template(name)
	ERB.new(File.read("templates/#{name}.erb"), nil, '-').result
end

def page(name)
	@bodyid = name
	html = template('header')
	html << template(name)
	html << template('footer')
end

def h(str)
	ERB::Util.html_escape(str)
end

def file_writer(dir)
	Proc.new do |filename, contents|
		File.open(dir + '/' + filename, 'w') do |f|
			f.puts contents
		end
	end
end

def translations(lang)
	t = Object.new
	t9n = JSON.parse(File.read('t9n/' + lang + '.json'), symbolize_names: true)
	t9n.each do |k,v|
		t.define_singleton_method(k, Proc.new{v})
	end
	t
end

# for rel alternate header: returns hash of langcode => url
def alternates(langhash, thislang, thispage)
	others = {}
	(langhash.keys - [thislang]).each do |l|
		subdomain = (l == 'en') ? '' : "#{l}."
		others[l] = 'http://%smusicthoughts.com/%s' % [subdomain, thispage]
	end
	others
end

# Returns first 10 words or first 20 characters of quote
def snip_for_lang(str, language_code)
	if ['zh', 'ja'].include? language_code
		return (str[0,20] + '…')
	else
		return (str.split(' ')[0,10].join(' ') + '…')
	end
end

@languages = {
	'en' => 'English',
	'es' => 'Español',
	'fr' => 'Français',
	'de' => 'Deutsch',
	'it' => 'Italiano',
	'pt' => 'Português',
	'ru' => 'Русский',
	'ar' => 'العربية',
	'ja' => '日本語',
	'zh' => '中文'}

@languages.each do |lang, langname|
	# file-writing shortcut used everywhere below
	f = file_writer('site/' + lang)

	# get all approved thoughts & random thoughts.  write json
	ok, approved_thoughts = db.call('approved_thoughts', lang)
	f.call('thoughts.json', approved_thoughts.to_json)

	ok, random_thoughts = db.call('random_thoughts', lang)
	f.call('random.json', random_thoughts.to_json)

	# vars for all templates
	@t = translations(lang)
	@lang = lang
	@dir = (lang == 'ar') ? 'rtl' : 'ltr'

	# write home
	@rel_alternate = alternates(@languages, lang, '')
	f.call('home', page('home'))

	# write approved thought pages
	# write author pages
	# write contributor pages
end

