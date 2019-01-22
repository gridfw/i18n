gulp			= require 'gulp'
gutil			= require 'gulp-util'
# minify		= require 'gulp-minify'
include			= require "gulp-include"
uglify			= require 'gulp-uglify'
rename			= require "gulp-rename"
coffeescript	= require 'gulp-coffeescript'
PluginError		= gulp.PluginError
cliTable		= require 'cli-table'
cliTable		= require 'cli-table'
template		= require 'gulp-template' # compile some consts into digits

settings = 
	isProd: gutil.env.mode is 'prod'

# compile final values (consts to be remplaced at compile time)
# handlers
_compileCoffee = (mode, dest)->
	glp = gulp.src 'assets/**/[!_]*.coffee', nodir: true
		# include related files
		.pipe include hardFail: true
		.pipe template {mode}
		# convert to js
		.pipe coffeescript(bare: true).on 'error', errorHandler
		.pipe rename dest + '.js'
	# uglify when prod mode
	if settings.isProd
		glp = glp.pipe uglify()
	# save 
	glp.pipe gulp.dest 'build'
		.on 'error', errorHandler

compileCoffee = -> _compileCoffee 'node', 'index'
compileCoffeeBrowser= -> _compileCoffee 'browser', 'i18n-browser'

# watch files
watch = ->
	gulp.watch ['assets/**/*.coffee'], compileCoffee, compileCoffeeBrowser
	return

# error handler
errorHandler= (err)->
	# get error line
	expr = /:(\d+):(\d+):/.exec err.stack
	if expr
		line = parseInt expr[1]
		col = parseInt expr[2]
		code = err.code?.split("\n")[line-3 ... line + 3].join("\n")
	else
		code = line = col = '??'
	# Render
	table = new cliTable()
	table.push {Name: err.name},
		{Filename: err.filename},
		{Message: err.message},
		{Line: line},
		{Col: col}
	console.error table.toString()
	console.log '\x1b[31mStack:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', err.stack
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	console.log '\x1b[31mCode:'
	console.error '\x1b[0m┌─────────────────────────────────────────────────────────────────────────────────────────┐'
	console.error '\x1b[34m', code
	console.log '\x1b[0m└─────────────────────────────────────────────────────────────────────────────────────────┘'
	return

# default task
if settings.isProd
	gulp.task 'default', gulp.series compileCoffee, compileCoffeeBrowser
else
	gulp.task 'default', gulp.series compileCoffee, compileCoffeeBrowser, watch