###
Parse cookies
###
parseCookie = ->
	cookieHeader = @req.headers.cookie
	cookies = cookieHeader and (cookie.parse cookieHeader, settings) or Object.create null
	# parse JSON
	for k,v of cookies
		try
			# decode cookie if it is
			if _secret and v.startsWith 's.'
				v = AESCrypto.decrypt(v.substr(2), _secret).toString(CryptoJS.enc.Utf8)
			# parse json value
			if v.startsWith 'j.'
				cookies[k] = JSON.parse v.substr 2
			else
				cookies[k] = v.substr 2
		catch e
			@warn 'Cookie-parser', e
	# return value
	Object.defineProperty this, 'cookies', value: cookies
	Object.defineProperty this, 'signedCookies', value: cookies
	return cookies




