
/**

 * Clear caches

 */
/**
* _loadLocal
* TODO enable mem caching in prod
 */
/**
* Request wrapper
 */
/**
 * set context local
 * @param {string} local - local to set
 * @param {boolean} relaxed - if use parent local when missing (example: use "en" when "en-US" is messing)
 */
var Glob, I18N, I18N_LANG_FORMAT, Path, _clear, _loadI18nMap, _loadLocal, _reqWrapper, _setLocal, fs;

Glob = require('glob');

Path = require('path');

fs = require('mz/fs');

// map settings indexes
/**

 * Accepted i18n formats

 * en.js or en-US.js

 */
I18N_LANG_FORMAT = /^(?:[a-z]{2}|[a-z]{2}-[A-Z]{2})\.js$/;

_clear = function(i18n) {
  // clear caches
  i18n.m = null;
  i18n.c = Object.create(null);
};

// load i18n mapping files
_loadI18nMap = function(globSelector) {
  return new Promise(function(resolve, reject) {
    var result;
    result = Object.create(null);
    return Glob(globSelector, {
      nodir: true
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

_reqWrapper = function(i18n) {
  var _getLocal, settings;
  settings = i18n.s;
  // set local
  _getLocal = async function(param) {
    return ((await i18n.get(param))) || (param.length > 2) && ((await i18n.get(local.substr(0, 2))));
  };
  // wrapper
  return async function(ctx, next) {
    var e, fx, i18nObj, param, url;
    // set language
    if (param = ctx.query[settings[2]]) {
      if ((await _getLocal(param))) {
        settings[5](ctx, param);
      }
      // redirect
      url = new URL(ctx.url);
      url.searchParams.delete(settings[2]);
      return ctx.redirect(url);
    }
    try {
      // load context language if set
      if ((fx = settings[3])) {
        param = (await fx(ctx));
      } else {
        // load from session instead or use default one
        param = (await settings[4](ctx));
      }
      if (param == null) {
        param = settings[0];
      }
    } catch (error) {
      e = error;
      param = settings[0];
    }
    // load i18n
    i18nObj = (await _getLocal(param || settings[0]));
    if (i18nObj == null) {
      i18nObj = (await _getLocal(settings[0]));
    }
    // set this as current i18n
    Object.defineProperty(ctx, 'i18n', {
      value: i18nObj,
      configurable: true
    });
    Object.defineProperty(ctx.locals, 'i18n', {
      value: i18nObj,
      configurable: true
    });
    // exec hadnler fx
    return next();
  };
};

_setLocal = async function(local, relaxed) {
  var I18N, obj;
  // get i18n object
  I18N = this.app.i18n;
  obj = (await I18N.get(local));
  if (!obj) {
    if (relaxed && local.length > 2) {
      obj = (await I18N.get(local.substr(0, 2)));
    }
    if (!obj) {
      throw new Error(`Unknown local: ${local}`);
    }
  }
  // set this as current i18n
  Object.defineProperty(this, 'i18n', {
    value: obj,
    configurable: true
  });
  Object.defineProperty(this.locals, 'i18n', {
    value: obj,
    configurable: true
  });
};

_loadLocal = async function(local) {
  var i18n;
  // check if already in cache
  i18n = this.c[local];
  if (i18n) {
    return i18n;
  }
  // check in map
  i18n = this.m[local];
  if (!i18n) {
    return i18n;
  }
  // load from file
  i18n = eval((await fs.readFile(i18n)));
  // cache
  this.c[local] = i18n;
  // return
  return i18n;
};

I18N = class I18N {
  constructor(app) {
    this.app = app;
    this.enabled = true; // the plugin is enabled
    // cache
    this.m = null; // map supported languages: lg: path, en : '/path/en.js'
    this.c = Object.create(null); // store loaded langs
    this.s = [];
    // handler wrapper
    this._wrapper = _reqWrapper(this);
    // get local
    this.get = _loadLocal;
    // set as module
    Object.defineProperty(this.app, 'i18n', {
      value: this,
      configurable: true
    });
    return;
  }

  /**
   * Reload the app
   * @optional @param  {String} options.default - default local @default en or first local in the list
   * @optional @param {String} options.param - param name @default i18n
   * @param {String | [String]} options.locals - GLOB paths to local files
   * @optional @param {String} options.setLangParam - langParam name @default 'set-lang'
   * @optional @param {function} options.ctxLocal - current context language, will be use for current request only
   * @optional @param {String or object} options.session - get/set current local value
   * @optional @param {Boolean} cache - use i18n cache
   * @return self
   */
  async reload(options) {
    var defaultLocal, i, i18nMap, len, p, ref, session, sessionGet, sessionParam, sessionSet, settings;
    ref = ['default', 'param', 'setLangParam'];
    // ignore loading unless it has locals path
    // return unless options and 'locals' in options
    // check options
    for (i = 0, len = ref.length; i < len; i++) {
      p = ref[i];
      if (p in options && typeof options[p] !== 'string') {
        throw new Error(`options.${p} expected string`);
      }
    }
    if ('ctxLocal' in options && typeof options.ctxLocal !== 'function') {
      throw new Error('options.ctxLocal expected function');
    }
    if ('cache' in options && typeof options.cache !== 'boolean') {
      throw new Error('options.cache expected boolean');
    }
    // clear already set values
    _clear(this);
    // default local
    defaultLocal = options.default || 'en'; // default language
    // load files
    i18nMap = this.m = (await _loadI18nMap(options.locals || Path.join(process.cwd, 'i18n')));
    if (!(defaultLocal in i18nMap)) {
      throw new Error(`Default local [${defaultLocal}] is missing`);
    }
    // session management
    session = options.session;
    if (typeof session === 'object') {
      if (typeof session.set !== 'function') {
        throw new Error('session.set function is required');
      }
      if (typeof session.get !== 'function') {
        throw new Error('session.get function is required');
      }
      sessionGet = session.get;
      sessionSet = session.set;
    } else if (typeof session === 'string' || !session) {
      sessionParam = session || 'i18n';
      sessionGet = function(ctx) {
        return ctx.session.get(sessionParam);
      };
      sessionSet = function(ctx, value) {
        return ctx.session.set(sessionParam, value);
      };
    } else {
      throw new Error('Illegal options.session');
    }
    // settings
    settings = this.s;
    settings[0] = defaultLocal;
    settings[1] = options.param || 'i18n';
    settings[2] = options.setLangParam || 'set-lang';
    settings[3] = options.ctxLocal;
    settings[4] = sessionGet;
    settings[5] = sessionSet;
    // set local context method
    Object.defineProperty(this.app.Context, 'setLocal', {
      value: _setLocal,
      configurable: true
    });
    // enable plugin
    this.enable();
  }

  /**
   * destroy
   */
  destroy() {
    // disable i18n
    this.disable();
    // clear already set values
    _clear(this);
    // remove set local
    delete this.app.Context.setLocal;
    delete this.app.i18n;
  }

  /**
   * Disable, enable
   */
  disable() {
    // remove i18n wrapper
    this.app.unwrap(this._wrapper);
  }

  enable() {
    // add wrapper
    this.app.wrap(0, this._wrapper);
  }

  /**
   * Has
   */
  has(local) {
    return local in this.m;
  }

};

module.exports = I18N;
