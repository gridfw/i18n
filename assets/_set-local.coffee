###*
 * set context local
 * @param {string} local - local to set
 * @param {boolean} relaxed - if use parent local when missing (example: use "en" when "en-US" is messing)
###
_setLocal = (local, relaxed)->
	# get i18n object
	I18N = @app.i18n
	obj = await I18N.get local
	unless obj
		if relaxed and local.length > 2
			obj = await I18N.get local.substr(0,2)
		throw new Error "Unknown local: #{local}" unless obj
	# set this as current i18n
	Object.defineProperty this, 'i18n',
		value: obj
		configurable: on
	Object.defineProperty @locals, 'i18n',
		value: obj
		configurable: on
	return