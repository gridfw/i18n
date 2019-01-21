###*
 * _loadLocal
 * TODO enable mem caching in prod
###
_loadLocal = (local)->
	# check if already in cache
	i18n = @c[local]
	return i18n if i18n

	# check in map
	i18n = i18n.m[local]
	return i18n unless i18n

	# load from file
	i18n = eval await fs.readFile i18n
	# cache
	@c[local] = i18n
	# return
	return i18n