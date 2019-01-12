###*
 * Set cookie
 * @example
 * ctx.cookie('name', 'value', options)
###
setCookie= (name, value, options)->
	throw new Error 'Cookie name required' unless name
	options ?= Object.create null
	# stringify value
	if typeof value is 'string'
		value = '..' + value
	else if value?
		value = 'j.' + JSON.stringify value
	else
		value = '..'
	# signe cookie
	if _secret
		value = 's.' + AESCrypto.encrypt value, _secret
	# max age
	if 'maxAge' of options
		options.expires = new Date Date.now() + options.maxAge
	# path
	options.path ?= '/'
	# set as header
	@res.addHeader 'Set-Cookie', cookie.serialize name, value, options
	# chain
	this


###*
 * Clear cookie
 * @example
 * ctx.clearCookie('name', options)
###
clearCookie = (name, options)->
	options ?= Object.create null
	options.expires ?= new Date 1
	options.path	?= '/'
	@cookie name, '', options
