
/**
 * Accepted i18n formats
 * en.js or en-US.js
 */
var Glob, I18N, I18N_LANG_FORMAT, Path, _create, _defineProperty, _getFromCache, _loadI18nMap, _setLocal, fs;

Glob = require('glob');

Path = require('path');

fs = require('mz/fs');

_create = Object.create;

_defineProperty = Object.defineProperty;

I18N_LANG_FORMAT = /^(?:[a-z]{2}|[a-z]{2}-[A-Z]{2})\.js$/;

// set local
_setLocal = function(cache, map) {
  return async function(local, relaxed) {
    var err, i18n, i18nPath;
    try {
      // get local from map
      if (!((i18nPath = map[local]) || (relaxed && (i18nPath = map[local.substr(0, 2)])))) {
        throw new Error(`Unknown local: ${local}`);
      }
      i18n = (await cache.get(i18nPath));
      // set this as current i18n
      _defineProperty(this, 'i18n', {
        value: i18n,
        configurable: true
      });
      _defineProperty(this.locals, 'i18n', {
        value: i18n,
        configurable: true
      });
    } catch (error) {
      err = error;
      if (err === 404) {
        err = new Error(`I18N>> Could not find: ${i18nPath}`);
      } else if (typeof err === 'string') {
        err = new Error(`I18N>> ${err}`);
      }
      throw err;
    }
  };
};

// get local from cache
_getFromCache = function(cache, map) {
  return function(local) {
    var err;
    try {
      if (local = map[local]) {
        return cache.get(local);
      }
    } catch (error) {
      err = error;
      if (err === 404) {
        return null;
      }
      throw err;
    }
  };
};


// load i18n mapping files
_loadI18nMap = function(globSelector) {
  return new Promise(function(resolve, reject) {
    var result;
    result = Object.create(null);
    return Glob(globSelector, {
      nodir: true,
      absolute: true
    }, function(err, files) {
      var file, fileName, i, len;
      try {
        if (err) {
          // check
          throw err;
        }
        if (!files.length) {
          throw 'No i18n file found';
        }
// loop
        for (i = 0, len = files.length; i < len; i++) {
          file = files[i];
          fileName = Path.basename(file);
          if (!I18N_LANG_FORMAT.test(fileName)) {
            // check filename format
            throw new SyntaxError(`Illegal file name: [${fileName}], should matches: ${I18N_LANG_FORMAT}`);
          }
          // append
          fileName = fileName.slice(0, -3);
          if (fileName in result) {
            throw new Error(`Multiple files found for local: ${filename}`);
          }
          result[fileName] = file;
        }
        resolve(result);
      } catch (error) {
        err = error;
        reject(err);
      }
    });
  });
};

I18N = class I18N {
  constructor(app) {
    this.app = app;
    this.enabled = true; // the plugin is enabled
    // set as module
    _defineProperty(app, 'i18n', {
      value: this,
      configurable: true
    });
    return;
  }

  /**
   * Reload the app
   * @param {String | [String]} options.locals - GLOB paths to local files
   * @return self
   */
  async reload(options) {
    var i18nMap;
    if (options == null) {
      options = _create(null);
    }
    // load files
    this.map = i18nMap = (await _loadI18nMap(options.locals || Path.join(process.cwd(), 'i18n')));
    // get a local from cache
    this.get = _getFromCache(this.app.CACHE, i18nMap);
    // properties
    this.fxes = {
      Context: {
        setLocal: _setLocal(this.app.CACHE, i18nMap)
      }
    };
    // enable plugin
    this.enable();
  }

  /**
   * destroy
   */
  destroy() {
    // disable i18n
    this.disable();
    // remove set local
    delete this.app.i18n;
  }

  /**
   * Disable, enable
   */
  disable() {
    this.app.removeProperties('i18n', this.fxes);
  }

  enable() {
    this.app.addProperties('i18n', this.fxes);
  }

  /**
   * Has
   */
  has(local) {
    return local in this.map;
  }

};

module.exports = I18N;
