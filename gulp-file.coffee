gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require('gulp-uglify-es').default
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'

GfwCompiler		= require 'gridfw-compiler'

isProd= gutil.env.hasOwnProperty('prod')
settings = 
	mode: if isProd then 'prod' else 'dev'
	isProd: isProd
# compile final values (consts to be remplaced at compile time)
# handlers
_compileCoffee = (mode, dest)->
	glp = gulp.src "assets/#{mode}.coffee"
		# include related files
		.pipe include hardFail: true
		.pipe GfwCompiler.template(settings).on 'error', GfwCompiler.logError
		# convert to js
		.pipe coffeescript(bare: true).on 'error', GfwCompiler.logError
		.pipe rename dest + '.js'
	# uglify when prod mode
	if settings.isProd
		glp = glp.pipe uglify()
	# save 
	glp.pipe gulp.dest 'build'
		.on 'error', GfwCompiler.logError

compileCoffee = -> _compileCoffee 'node', 'index'
# compileCoffeeBrowser= -> _compileCoffee 'browser', 'i18n-browser'

# watch files
watch = (cb)->
	unless settings.isProd
		gulp.watch ['assets/**/*.coffee'], compileCoffee #, compileCoffeeBrowser
	cb();
	return

# default task ,compileCoffeeBrowser
gulp.task 'default', gulp.series compileCoffee, watch