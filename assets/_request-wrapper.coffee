###*
* Request wrapper
###
_reqWrapper = (i18n)->
	settings = i18n.s
	# set local
	_getLocal = (param)->
		return (await i18n.get param) || (param.length > 2) && (await i18n.get local.substr 0,2)
	# wrapper
	(ctx, next)->
		# set language
		if param = ctx.query[settings[<%= settings.setLangParam %>]]
			if await _getLocal param
				settings[<%= settings.sessionSet %>] ctx, param
			# redirect
			url = new URL ctx.url
			url.searchParams.delete settings[<%= settings.setLangParam %>]
			return ctx.redirect url
		try
			# load context language if set
			if (fx = settings[<%= settings.ctxLocal %>])
				param = await fx ctx
			# load from session instead or use default one
			else
				param = await settings[<%= settings.sessionGet %>] ctx
			param ?= settings[<%= settings.default %>]
		catch e
			param= settings[<%= settings.default %>]
		# load i18n
		i18nObj = await _getLocal param || settings[<%= settings.default %>]
		i18nObj ?= await _getLocal settings[<%= settings.default %>]
		# set this as current i18n
		Object.defineProperty this, 'i18n',
			value: i18nObj
			configurable: on
		Object.defineProperty @locals, 'i18n',
			value: i18nObj
			configurable: on
		# exec hadnler fx
		return next()
