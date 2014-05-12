gulp            = require "gulp"
browserSync     = require "browser-sync"

coffee          = require "gulp-coffee"
coffeelint      = require "gulp-coffeelint"

concat          = require "gulp-concat"

gulpif          = require "gulp-if"

imagemin        = require "gulp-imagemin"
jade            = require "gulp-jade"
minifyCSS       = require "gulp-minify-css"
notify          = require "gulp-notify"
plumber         = require "gulp-plumber"
prefix          = require "gulp-autoprefixer"
stylus          = require "gulp-stylus"
uglify          = require "gulp-uglify"
# runSequence     = require "run-sequence"
# uncss           = require "gulp-uncss"
modRewrite      = require 'connect-modrewrite'

common          = require 'gulp-commonjs'
rename          = require 'gulp-rename'
insert          = require 'gulp-insert'
gutil           = require 'gulp-util'
size            = require 'gulp-size'


# Defaults

dest = "./public"
src = "./app"

# END Defaults

# Another solution

targets =
  css     : "application.css"
  js      : "application.js"
  jsMin   : "application.min.js"
  jade    : "templates.js"
  lib     : "libs.js"
  scripts : "scripts.js"
  coffee  : "coffee.js"
  modules : "modules.js"

paths =
  stylus: ["css/index.styl"]
  coffee: [
    "#{src}/**/*.coffee"
    "#{src}/**/*.litcoffee"
  ]
  js: ["#{src}/**/*.js"]
  jade: ["#{src}/**/*.jade"]
  libs: [
    "node_modules/jade/runtime.js"
    "node_modules/node-uuid/uuid.js"
    "node_modules/commonjs-require-definition/require.js"
  ]
  modules: [
   "nex/lib/nex"
   "nex/lib/utils"
   "nex/lib/models"
   "nex/lib/panel"
   "nex/lib/widgets"
   "nex/lib/page"
   "nex/lib/contact"
   "nex/lib/search"
   "nex/lib/jquery.viewport"
   "nex/lib/image"
   "nex/lib/video"
   "nex/lib/slider"
   "nex/lib/html"
   "json2ify"
   "es5-shimify"
   "underscore"
   "jqueryify"
   "spine/lib/spine"
   "spine/lib/local"
   "spine/lib/relation"
   "spine/lib/ajax"
   "spine/lib/route"
   "spine/lib/manager"
   "spine/lib/list"
 ]

gulp.task "modules", ->
  files = (require.resolve(module) for module in paths.modules)
  gulp.src(files, base: __dirname)
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe rename (path) ->
      path.extname = ""
      path.dirname = path.dirname
      .split('node_modules/')[1]
      path.basename = '' if path.basename is 'index'
      path.dirname = '' if path.basename in ['spine', path.dirname]
      path
    .pipe common()
    .pipe concat targets.modules
    .pipe gulp.dest dest

gulp.task "jade", ->
  gulp.src paths.jade
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe jade(client: true).on('error', reportError)
    .pipe insert.prepend "module.exports = "
    .pipe rename extname: ""
    .pipe common()
    .pipe concat targets.jade
    .pipe gulp.dest dest

gulp.task "scripts", ->
  gulp.src paths.js
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe rename extname: ""
    .pipe common()
    .pipe concat targets.scripts
    .pipe gulp.dest dest

gulp.task "coffee", ->
  gulp.src paths.coffee
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe coffee(bare: true).on('error', reportError)
    .pipe coffeelint()
    .pipe rename extname: ""
    .pipe common()
    .pipe concat targets.coffee
    .pipe gulp.dest dest

generateCss = (production = false) ->
  gulp.src paths.stylus
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe stylus({errors: true, set:["compress"]})
    .pipe prefix("last 1 version")
    .pipe concat targets.css
    .pipe gulp.dest dest
    .pipe browserSync.reload({stream:true})

gulp.task "stylus", generateCss

gulp.task "libs", ->
  gulp.src paths.libs
    .pipe concat targets.lib
    .pipe gulp.dest dest

gulp.task "js", ["libs", "modules", "scripts", "coffee", "jade"], (next) ->
  next()

minify = ->
  gulp.src "#{dest}/#{targets.js}"
    .pipe uglify()
    .pipe concat targets.jsMin
    .pipe gulp.dest dest

combineJs = (production = false) ->
  # We need to rethrow jade errors to see them
  rethrow = (err, filename, lineno) -> throw err

  files = [
    targets.lib
    targets.modules
    targets.scripts
    targets.coffee
    targets.jade
  ]
  sources = files.map (file) -> "#{dest}/#{file}"

  gulp.src sources
    .pipe concat targets.js
    .pipe insert.append "jade.rethrow = #{rethrow.toLocaleString()};"
    .pipe gulp.dest dest
    .pipe browserSync.reload({stream:true})

gulp.task "combine", combineJs

gulp.task "watch", ["server"], ->

  gulp.watch "**/*.styl", {interval: 1000}, ['stylus']
  gulp.watch paths.jade, {interval: 2000}, ['jade']
  gulp.watch paths.coffee, {interval: 2000}, ['coffee']
  gulp.watch paths.js, {interval: 2000}, ['scripts']

  files = [targets.scripts, targets.jade, targets.coffee]
  sources = ("#{dest}/#{file}" for file in files)

  gulp.watch sources, {interval: 1000}, ['combine']

reportError = (err) ->
  gutil.beep()
  gutil.log err
  @emit 'end'

gulp.task "prepare", ["js"], ->
  generateCss()
  combineJs()

gulp.task "build", ["js"], ->
  production = true
  generateCss(production)
  combineJs(production)

gulp.task "server", ["prepare"], ->
  browserSync.init ["#{src}/index.html"],
    server:
      baseDir: "#{dest}"
      middleware: [
        modRewrite ['^([^.]+)$ /index.html [L]']
      ]
    debugInfo: false
    notify: false

gulp.task "default", ["watch"]