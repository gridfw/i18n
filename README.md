# gridfw-i18n
fast i18n plugin for Gridfw

## Configuration:

config via code
```javascript
gridfw = require('gridfw');

gridfw.i18n.configure({
	// @optional: Load locals from URI
	uri: '/path/to/i18n.json', // include single file that contains all required locals
	uri: 'https://example.com/path/to/remote/i18n.json', // load remote file
	uri: ['/path/to/i18n-1.json', '/path/to/i18n-2.json'], // include multiple i18n files
	uri: '/path/**/*.i18n.json', // include files using GLOB method (local files only)

	// @optional: Load locals directly from data object
	data: {locals}

	// default local
	default: 'en',
});

```

### Configure via Config file (recommanded)
See Gridfw file for more information
Inside your config file, add the following:
```javascript
{
	plugins:{
		//...
		"i18n": {
			"require": "gridfw-i18n",
			// @optional: Load from URI
			"uri": '/path/to/**/*.json',
			// default local
			"default": "en"
		}
	}
}
```

### Tips
* The framework will look for locals inside "/i18n/\*.json" in your app directory path unless you configure "uri" or "data" options.
* Use i18n file generator bellow instead of directly create JSONs

```javascript
```
