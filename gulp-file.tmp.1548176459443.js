var PluginError, _compileCoffee, cliTable, coffeescript, compileCoffee, compileCoffeeBrowser, errorHandler, gulp, gutil, include, rename, settings, template, uglify, watch;

gulp = require('gulp');

gutil = require('gulp-util');

// minify		= require 'gulp-minify'
include = require("gulp-include");

uglify = require('gulp-uglify');

rename = require("gulp-rename");

coffeescript = require('gulp-coffeescript');

PluginError = gulp.PluginError;

cliTable = require('cli-table');

cliTable = require('cli-table');

template = require('gulp-template'); // compile some consts into digits

settings = {
  isProd: gutil.env.mode === 'prod'
};

// compile final values (consts to be remplaced at compile time)
// handlers
_compileCoffee = function(mode, dest) {
  var glp;
  glp = gulp.src('assets/**/[!_]*.coffee', {
    nodir: true
  // include related files
  }).pipe(include({
    hardFail: true
  // convert to js
  })).pipe(template({mode})).pipe(coffeescript({
    bare: true
  }).on('error', errorHandler)).pipe(rename(dest + '.js'));
  // uglify when prod mode
  if (settings.isProd) {
    glp = glp.pipe(uglify());
  }
  // save 
  return glp.pipe(gulp.dest('build')).on('error', errorHandler);
};

compileCoffee = function() {
  return _compileCoffee('node', 'index');
};

compileCoffeeBrowser = function() {
  return _compileCoffee('browser', 'i18n-browser');
};

// watch files
watch = function() {
  gulp.watch(['assets/**/*.coffee'], compileCoffee, compileCoffeeBrowser);
};

// error handler
errorHandler = function(err) {
  var code, col, expr, line, ref, table;
  // get error line
  expr = /:(\d+):(\d+):/.exec(err.stack);
  if (expr) {
    line = parseInt(expr[1]);
    col = parseInt(expr[2]);
    code = (ref = err.code) != null ? ref.split("\n").slice(line - 3, line + 3).join("\n") : void 0;
  } else {
    code = line = col = '??';
  }
  // Render
  table = new cliTable();
  table.push({
    Name: err.name
  }, {
    Filename: err.filename
  }, {
    Message: err.message
  }, {
    Line: line
  }, {
    Col: col
  });
  console.error(table.toString());
  console.log('\x1b[31mStack:');
  console.error('\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐');
  console.error('\x1b[34m', err.stack);
  console.log('\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘');
  console.log('\x1b[31mCode:');
  console.error('\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐');
  console.error('\x1b[34m', code);
  console.log('\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘');
};

// default task
if (settings.isProd) {
  gulp.task('default', gulp.series(compileCoffee, compileCoffeeBrowser));
} else {
  gulp.task('default', gulp.series(compileCoffee, compileCoffeeBrowser, watch));
}
