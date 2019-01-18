# gridfw-i18n
fast i18n plugin for Gridfw

## Features
* Translate literals
* Pluralize literals
* Swith value depending on some value
* Text combining
* Compatible with Gridfw and Grid-Reactor 

## Configuration:

### config via code
```javascript
Gridfw = require('gridfw');

app = new Gridfw();

app.i18n.reload({
	default: 'en', // set as default local
	locals: '/path/to/locals/**/*.js'
});

// or like any other gridfw plugin via:
app.plugin('i18n').reload({...})

```
Locals are "js" files. See i18n gulp compiler to see how to create those files at: https://www.npmjs.com/package/gridfw-i18n-gulp

To keep memory usage minimal, the framework will use a memory cache and load useful files only depending on use.

### Configure via Config file (recommanded)
See Gridfw file for more information
Inside your config file, add the following:
```javascript
{
	plugins:{
		//...
		"i18n": {
			"require": "gridfw-i18n",
			"default": "en", // set default local, @default: en
			"locals": '/path/to/locals/*.js' // @default: i18n/*.js
		}
	}
}
```

### Options
	* param: String - i18n attribute name inside "ctx" and templates, @default: 'i18n' 
	* default: String - Contains default local to use when no one is selected
	* locals: String or list of Strings - GLOB path format to load all locals (will load only useful ones to memory depending on use)
	* setLangParam: String - name of query param that will be used to change language, @default: 'set-lang', Example: "?set-lang=en"
	* ctxLocal: function - see "Define local" section bellow

	* session: string or object - see session management bellow
	* cache: boolean - when true, use cache to optimize memory, load only required i18n files. load all otherwise @default: true

### Tips
* The framework will look for locals inside "/i18n/\*.js" in your app directory path unless you set "locals" option.
* Use gridfw-i18n-gulp to generate js files.
* Use Gridfw generator to generate your project.
* ctx.i18n.local is reserved, it will contains current local name

## Example of use:

### Step 1: Create i18n source files and compile theme
see gridfw-i18n-gulp for more options on how to create your i18n files
```coffeescript
appName: 'My app' # This message will be available for all locals

'hello %name':
	en: 'Hello #{self.name}'
	fr: 'Bonjour #{self.name}'

'you need x tickets':
	en: i18n.switch 'tickets.length',
		0: 'You need no ticket'
		1: 'You need one ticket'
		2: 'You need two tickets'
		else: 'You need #{self.tickets.length} tickets'
	fr: ...

# you can use PUGJS format, and nested messages it will be precompiled for ultra performance
'%name, you need x tickets now': '[b #{self.name}], #{i18n["you need x tickets"](self)} [span.danger now]'
```
At compile time, there are two cases:
* If the text contains variables, it will be compiled to a function that accepts a map of those variables. Example:
'hello #{self.name}' will be compiled to: function({name}){...}
* Otherwise, the text will be prerendered (compile pugjs content), and returned as text. Example:
'this is [span.danger very urgent]' will be compiled to: this is <span>very urgent</span>

### Step 2: use it inside your code:
```javascript
app.get '/my/app', (ctx)->
	appName = ctx.i18n.appName;
	greeting = ctx.i18n['hello %name']({name: 'mec'});

```
Or in any template engine you use:
```pug
html
	head
	body
		div App name: #{i18n.appName}
		div #{i18n['hello %name'](user)}
```

### Tips:
if you use "gridfw-compiler" to organize and conditional compile your code
use "<%= i18n.key %>" instead of "i18n.key" this will print "\_i18n[key_index]".
While i18n is a map of key: value, \_i18n is an array. it is 10x faster, but you need to know index instead of the key. "gridfw-compiler" will do conversion for you.
if you use "self" or any other root object in your templates, it will be: "self.<%= i18n.key %>" instead of "self.i18n.key"

## Define local:

### Permanent local:
A user local will be stored inside his session.
Every page with no temporary local will be shown in this local.

To change a user local:
* call URL: http://<your-domain>/<target-path-after-local-set>?anyparam=...&set-lang=<target-local>. will result a redirection to target URL

* use: await ctx.setLocal('<target-local>') # this will load local data, change ctx.i18n and ctx.locals.i18n

### Temporary local: Recommanded for pages depending on search engines
You can define a page language depending on a visible param inside the URL. This make each page looks depending on the target local.

There are two common possibilities
* <your-domain>/<target-path-after-local-set>?anyParam...&lang=<target-local>
* <your-domain>/<target-local>/<target-path-after-local-set>?anyParam...

The seconde one is the most recommanded.

The first example is the simplest: just add the "ctxLocal" option as follow
```javascript
app.i18n.reload({
	//... other options
	ctxLocal: (ctx) => ctx.query.lang
	});
```

The second options (that is recommanded for websites) needs special attention.
This approche could be confusing with routing logic. so be careful.
* The first step is: extract the language param
* The seconde step will be to rewrite the path, so the router will not see the language param
"ctxLocal" will be called inside a request handler wrapper (see app.wrap method). It will be called before the routing system and will contains no path param or any resolved values.

See this example on how to do this
```javascript
app.i18n.reload({
	ctxLocal: function(ctx){
		// Resolve the lang param
		matches = ctx.path.match(/^\/([a-z]*)(.*)/);

		// Rewrite the path so the lang param is invisible by the routing system
		ctx.path = matches[2];

		// return the lang value
		return matches[1]
	}
});
```
Simple! isn't it :)
You can implement more complexe format as you want.

## Session management:
By default, the framework will store the current local inside the user session under variable: "i18nLocal"

You can change this param name via option:
```javascript
app.i18n.reload({
	//... other options
	session: 'your_custom_param'
});
```

You can do more on setting your custom logic to get and store this value yourself.
You can use sync or async functions, return promises ...
```javascript
app.i18n.reload({
	//... other options
	session:{
		get: async function(ctx){
			// do what ever you want, it's async!
			var lang= await ctx.session.get('i18nParam');
			return lang;
		},
		set: function(ctx, lang){
			ctx.session.set('i18nParam', lang)
		}
	}
});
```

## Global methods:
```javascript
/**
 * Load EN locals
 * @return {
 *	messages: Object - contains all mapped messages (key: value)
 *	arr: Array - contains indexed messages
 *	map: Object - map kies to indexes
 * }
 */
i18nEN = await app.i18n.get('en');
i18nEN.messages.local === 'en'

/**
 * Is a local is supported
 */
app.i18n.has('fr-FR') // is fr-FR is supported

/**
 * Get a list of all supported locals names
 * This is a Getter
 */
app.i18n.locals # returns ['en', ...]

/**
 * Get list of current loaded locals names
 * (in cache)
 * This is a Getter
 */
app.i18n.loaded # returns ['en', ...]
```

## Client side useful methods
```javascript
/**
 * Load locals from an object.
 * TIP: You can use static files or JSONP
 */
I18N.load({fr:{...}, en:{...}});
```