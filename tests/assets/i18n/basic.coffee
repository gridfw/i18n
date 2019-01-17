###
# You can use "Gulp-include", so you split this file into multiple ones
###

###*
 * Add a common text for all languages
###
test_key: 'Common value on all languages'

###*
 * You can use Pug language to format your text or use native HTML
###
'This is a key with some #{var}': 'This is #[b key] with some #{self.var1} and <i>HTML</i>'
# will be compiled to: 'This is '.concat('<b>key</b>').concat(' with some ').concat(gulp.escape(var)).concat(' and <i>HTML</i>')

###*
 * To add a variable:
 * use #{javascript expression}, return value will be escaped
 * use !{javascript expression}, returned value will not be escaped
 * @see  Pug language
###
'test %firstName, %age': 'Test #{self.firstName_willbe_escaped}, !{self.age_will_not_be_escaped}'

###*
 * Using multi-lines
###
'Test multi-lines': """
	Test multi-
	span lines
	#[b any tag needs to be inside brackets]
	"""

### ========================================================= ***
 * Multiple languages
 ***========================================================= ###
'hello %name':
	en: 'Hello #{self.name}'
	fr: 'Bonjour #{self.name}'
	it: 'Buongiorno #{self.name}'

### ========================================================= ***
 * Multiple Format depending on a variable value
 ***========================================================= ###
'you need %count tickets': i18n.switch 'count',
	0: 'you need no ticket'
	1: 'you need one ticket'
	2: 'you need two tickets'
	'many': 'you need many tickets'
	# default value when all previous do not match
	else: 'you need #{self.count} tickets'


### ========================================================= ***
 * include an other i18n value
 ***========================================================= ###
'user has shared': i18n.switch 'users.length',
	0: 'No user had shared'
	1: '#{self.users[0].name} has shared'
	2: '#{self.users[0].name} and #{self.user[1].name} had shared'
	else: '#{users[0].name} and #{self.users.length} others had shared'
	
'a folder': i18n.switch 'folders.length', # if some key contains "." use table to describe path, example: i18n.switch ['fold.er', 'length']
	0: 'no folder'
	1: 'one folder'
	2: 'two folders'
	else: '#{self.folders.length} folders'

'user has shared a folder with you': '#{i18n["user has shared"](users)} #{i18n["a folder"](folders)} with you'

