###*
 * set context local
 * @param {string} local - local to set
 * @param {boolean} relaxed - if use parent local when missing (example: use "en" when "en-US" is messing)
###
_setLocal = (local, relaxed)->
	# get i18n object
	obj = await @app.i18n.get local
	unless obj
		if relaxed and local.length > 2
			obj = await @app.i18n.get local.substr(0,2)
		throw new Error "Unknown local: #{local}"
	# set this as current i18n
	Object.defineProperty this, 'i18n',
		value: obj
		configurable: on
	Object.defineProperty @locals, 'i18n',
		value: obj
		configurable: on
	return