###*
 * This contains your gulp file configuration in coffee script
###
gulp = require 'gulp'
gutil = require 'gulp-util'
coffeescript= require 'gulp-coffeescript'
Gi18nCompiler = require 'gridfw-i18n-gulp'


# Compile i18n files
compileI18n = ->
	gulp.src 'assets/i18n/**/*.coffee'
		.pipe coffeescript bare: true
		.pipe Gi18nCompiler()
		.pipe gulp.dest 'build/i18n'
		.on 'error', gutil.log