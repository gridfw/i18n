
class I18N
	constructor: ->

	###*
	 * Reload the app
	 * @optional @param  {String} options.default - default local @default en or first local in the list
	 * @optional @param {String} options.param - param name @default i18n
	 * @param {String | [String]} options.locals - GLOB paths to local files
	 * @optional @param {String} options.setLangParam - langParam name @default 'set-lang'
	 * @optional @param {function} options.ctxLang - current context language, will be use for current request only
	 * @optional @param {String or object} options.session - get/set current local value
	 * @optional @param {Boolean} cache - use i18n cache
	 * @return self
	###
	reload: (options)->