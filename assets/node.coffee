Glob = require 'glob'
Path = require 'path'
fs	= require 'mz/fs'

_create= Object.create
_defineProperty= Object.defineProperty
###*
 * Accepted i18n formats
 * en.js or en-US.js
###
I18N_LANG_FORMAT = /^(?:[a-z]{2}|[a-z]{2}-[A-Z]{2})\.js$/

# set local
_setLocal = (cache, map)->
	(local, relaxed)->
		try
			# get local from map
			unless (i18nPath= map[local]) or (relaxed and i18nPath= map[local.substr(0,2)])
				throw new Error "Unknown local: #{local}"
			i18n= await cache.get i18nPath
			# set this as current i18n
			_defineProperty this, 'i18n',
				value: i18n
				configurable: on
			_defineProperty @locals, 'i18n',
				value: i18n
				configurable: on
		catch err
			if err is 404
				err= new Error "I18N>> Could not find: #{i18nPath}"
			else if typeof err is 'string'
				err= new Error "I18N>> #{err}"
			throw err
		return

# get local from cache
_getFromCache= (cache, map)->
	(local)->
		try
			if local= map[local]
				cache.get local
		catch err
			return null if err is 404
			throw err
		

# load i18n mapping files
_loadI18nMap = (globSelector)->
	new Promise (resolve, reject)->
		result = Object.create null
		Glob globSelector, {nodir:yes, absolute:yes}, (err, files)->
			try
				# check
				throw err if err
				throw 'No i18n file found' unless files.length
				# loop
				for file in files
					fileName = Path.basename file
					# check filename format
					throw new SyntaxError "Illegal file name: [#{fileName}], should matches: #{I18N_LANG_FORMAT}" unless I18N_LANG_FORMAT.test fileName
					# append
					fileName = fileName.slice 0, -3
					throw new Error "Multiple files found for local: #{filename}" if fileName of result
					result[fileName] = file
				resolve result
			catch err
				reject err
			return


class I18N
	constructor: (app)->
		@app= app
		@enabled = on # the plugin is enabled
		# set as module
		_defineProperty app, 'i18n',
			value: this
			configurable: on
		_defineProperty app.locals, 'I18N',
			value: this,
			configurable: on
		return
	###*
	 * Reload the app
	 * @param {String | [String]} options.locals - GLOB paths to local files
	 * @return self
	###
	reload: (options)->
		options ?= _create null
		# load files
		@map= i18nMap= await _loadI18nMap options.locals or Path.join process.cwd(), 'i18n'
		@keys= @locals= Object.keys i18nMap
		# supported languages
		lng= []
		for lc in @keys
			lc= lc.substr 0, 2 if lc.length > 2
			lng.push lc unless lc in lng
		@languages= lng
		# get a local from cache
		@get= _getFromCache @app.CACHE, i18nMap
		# properties
		@fxes=
			Context:
				setLocal: _setLocal @app.CACHE, i18nMap
		# enable plugin
		@enable()
		return
	###*
	 * destroy
	###
	destroy: ->
		# disable i18n
		@disable()
		# remove set local
		delete @app.i18n
		return
	###*
	 * Disable, enable
	###
	disable: ->
		@app.removeProperties 'i18n', @fxes
		return

	enable: ->
		@app.addProperties 'i18n', @fxes
		return

	###*
	 * Has
	###
	has: (local)-> local of @map

module.exports= I18N