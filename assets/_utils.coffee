###*
 * Accepted i18n formats
 * en.js or en-US.js
###
I18N_LANG_FORMAT = /^(?:[a-z]{2}|[a-z]{2}-[A-Z]{2})\.js$/

###*
 * Clear caches
###
_clear = (i18n)->
	# clear caches
	i18n.m = null
	i18n.c = Object.create null
	return

# load i18n mapping files
_loadI18nMap = (globSelector)->
	new Promise (resolve, reject)->
		result = Object.create null
		Glob globSelector, {nodir:yes}, (err, files)->
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
				
