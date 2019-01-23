Glob = require 'glob'
Path = require 'path'
fs	= require 'mz/fs'

# map settings indexes
<%
var settings ={
	default: 0,
	param: 1,
	setLangParam: 2,
	ctxLocal: 3,
	sessionGet: 4,
	sessionSet: 5
};
%>

#=include _utils.coffee
#=include _request-wrapper.coffee
#=include _set-local.coffee
#=include _load-local-nodejs.coffee

class I18N
	constructor: (@app)->
		@enabled = on # the plugin is enabled
		# cache
		@m = null # map supported languages: lg: path, en : '/path/en.js'
		@c= Object.create null # store loaded langs
		@s= []
		# handler wrapper
		@_wrapper = _reqWrapper this
		# get local
		@get = _loadLocal
		# set as module
		Object.defineProperty @app, 'i18n',
			value: this
			configurable: on
		return
	###*
	 * Reload the app
	 * @optional @param  {String} options.default - default local @default en or first local in the list
	 * @optional @param {String} options.param - param name @default i18n
	 * @param {String | [String]} options.locals - GLOB paths to local files
	 * @optional @param {String} options.setLangParam - langParam name @default 'set-lang'
	 * @optional @param {function} options.ctxLocal - current context language, will be use for current request only
	 * @optional @param {String or object} options.session - get/set current local value
	 * @optional @param {Boolean} cache - use i18n cache
	 * @return self
	###
	reload: (options)->
		# ignore loading unless it has locals path
		# return unless options and 'locals' in options
		# check options
		for p in ['default', 'param', 'setLangParam']
			throw new Error "options.#{p} expected string" if p of options and typeof options[p] isnt 'string'
		throw new Error 'options.ctxLocal expected function' if 'ctxLocal' of options and typeof options.ctxLocal isnt 'function'
		throw new Error 'options.cache expected boolean' if 'cache' of options and typeof options.cache isnt 'boolean'
		# clear already set values
		_clear this
		# default local
		defaultLocal = options.default || 'en' # default language
		# load files
		i18nMap= @m= await _loadI18nMap options.locals || Path.join process.cwd, 'i18n'
		throw new Error "Default local [#{defaultLocal}] is missing" unless defaultLocal of i18nMap
		# session management
		session = options.session
		if typeof session is 'object'
			throw new Error 'session.set function is required' unless typeof session.set is 'function'
			throw new Error 'session.get function is required' unless typeof session.get is 'function'
			sessionGet = session.get
			sessionSet = session.set
		else if typeof session is 'string' or not session
			sessionParam= session || 'i18n'
			sessionGet= (ctx) -> ctx.session.get sessionParam
			sessionSet= (ctx, value) -> ctx.session.set sessionParam, value
		else
			throw new Error 'Illegal options.session'
		# settings
		settings = @s
		settings[<%= settings.default %>]= defaultLocal
		settings[<%= settings.param %>]= options.param || 'i18n'
		settings[<%= settings.setLangParam %>]= options.setLangParam || 'set-lang'
		settings[<%= settings.ctxLocal %>]= options.ctxLocal
		settings[<%= settings.sessionGet %>]= sessionGet
		settings[<%= settings.sessionSet %>]= sessionSet
		# set local context method
		Object.defineProperty @app.Context, 'setLocal',
			value: _setLocal
			configurable: on
		# enable plugin
		@enable()
		return
	###*
	 * destroy
	###
	destroy: ->
		# disable i18n
		@disable()
		# clear already set values
		_clear this
		# remove set local
		delete @app.Context.setLocal
		delete @app.i18n
		return
	###*
	 * Disable, enable
	###
	disable: ->
		# remove i18n wrapper
		@app.unwrap @_wrapper
		return

	enable: ->
		# add wrapper
		@app.wrap 0, @_wrapper
		return

	###*
	 * Has
	###
	has: (local)-> local of @m

module.exports= I18N