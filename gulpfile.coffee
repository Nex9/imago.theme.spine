gulp            = require 'gulp'
browserSync     = require 'browser-sync'
reload          = browserSync.reload

coffee          = require 'gulp-coffee'
coffeelint      = require 'gulp-coffeelint'

concat          = require 'gulp-concat'

jade            = require 'gulp-jade'
plumber         = require 'gulp-plumber'
prefix          = require 'gulp-autoprefixer'
stylus          = require 'gulp-stylus'
sass            = require 'gulp-ruby-sass'
uglify          = require 'gulp-uglify'
modRewrite      = require 'connect-modrewrite'

common          = require 'gulp-commonjs'
rename          = require 'gulp-rename'
insert          = require 'gulp-insert'
gutil           = require 'gulp-util'
sourcemaps      = require 'gulp-sourcemaps'
watch           = require 'gulp-watch'
Notification    = require 'node-notifier'
notifier        = new Notification()
exec            = require('child_process').exec


# Defaults

dest = 'public'
src = 'app'

# END Defaults

# Another solution

targets =
  css     : 'application.css'
  js      : 'application.js'
  jsMin   : 'application.js'
  jade    : 'templates.js'
  lib     : 'libs.js'
  scripts : 'scripts.js'
  coffee  : 'coffee.js'
  modules : 'modules.js'

paths =
  stylus: ['css/index.styl']
  sass: ['css/index.sass']
  coffee: [
    "#{src}/**/*.coffee"
    "#{src}/**/*.litcoffee"
  ]
  js: ["#{src}/**/*.js"]
  jade: ["#{src}/**/*.jade"]
  nexDev: ['node_modules/nex/lib/*.js']
  libs: [
    'node_modules/jade/runtime.js'
    'node_modules/commonjs-require-definition/require.js'
  ]
  modules: [
   'nex/lib/nex'
   'nex/lib/utils'
   'nex/lib/models'
   'nex/lib/panel'
   'nex/lib/widgets'
   'nex/lib/page'
   'nex/lib/contact'
   'nex/lib/search'
   'nex/lib/jquery.viewport'
   'nex/lib/image'
   'nex/lib/video'
   'nex/lib/slider'
   'nex/lib/tabs'
   'nex/lib/html'
   'json2ify'
   'es5-shimify'
   'underscore'
   'jqueryify'
   'spine/lib/spine'
   'spine/lib/local'
   'spine/lib/relation'
   'spine/lib/ajax'
   'spine/lib/route'
   'spine/lib/manager'
   'spine/lib/list'
 ]

gulp.task 'modules', ->
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

gulp.task 'jade', ->
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

gulp.task 'scripts', ->
  gulp.src paths.js
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe rename extname: ""
    .pipe common()
    .pipe concat targets.scripts
    .pipe gulp.dest dest

gulp.task 'coffee', ->
  gulp.src paths.coffee
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe coffeelint()
    .pipe coffee(bare: true).on('error', reportError)
    .pipe rename extname: ""
    .pipe common()
    .pipe concat targets.coffee
    .pipe gulp.dest dest

generateStylus = (production = false) ->
  gulp.src paths.stylus
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe stylus({errors: true, use: ['nib'], set:['compress']})
    .pipe prefix('last 2 versions')
    .pipe concat targets.css
    .pipe gulp.dest dest
    .pipe reload({stream:true})

gulp.task 'stylus', generateStylus

generateSass = (production = false) ->
  gulp.src paths.sass
    .pipe plumber(
      errorHandler: reportError
    )
    .pipe sass()
    .pipe prefix('last 2 versions')
    .pipe concat targets.css
    .pipe gulp.dest dest
    .pipe reload({stream:true})

gulp.task 'sass', generateSass

gulp.task 'libs', ->
  gulp.src paths.libs
    .pipe concat targets.lib
    .pipe gulp.dest dest

gulp.task 'js', ['libs', 'modules', 'scripts', 'coffee', 'jade'], (next) ->
  next()

minifyJs = ->
  gulp.src "#{dest}/#{targets.js}"
    .pipe uglify()
    .pipe gulp.dest dest

gulp.task 'minify', ['combineBuild'], minifyJs

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
    .pipe sourcemaps.init()
    .pipe concat targets.js
    .pipe insert.append "jade.rethrow = #{rethrow.toLocaleString()};"
    .pipe sourcemaps.write './maps'
    .pipe gulp.dest dest
    .pipe browserSync.reload {stream:true}

gulp.task 'combine', combineJs

gulp.task 'combineBuild', ['js'], combineJs

gulp.task 'watch', ['sass', 'stylus', 'combine', 'browser-sync'], ->

  watch
    glob: '**/*.sass', emitOnGlob: false
  , ->
    gulp.start('sass')

  watch
    glob: '**/*.styl', emitOnGlob: false
  , ->
    gulp.start('stylus')

  watch
    glob: paths.jade, emitOnGlob: false
  , ->
    gulp.start('jade')

  watch
    glob: paths.coffee, emitOnGlob: false
  , ->
    gulp.start('coffee')

  watch
    glob: paths.nexDev, emitOnGlob: false
  , ->
    gulp.start('modules')

  watch
    glob: paths.js, emitOnGlob: false
  , ->
    gulp.start('scripts')

  files = [targets.jade, targets.coffee, targets.scripts]
  sources = ("#{dest}/#{file}" for file in files)

  watch
    glob: sources, emitOnGlob: false
  , ->
    gulp.start('combine')

reportError = (err) ->
  gutil.beep()
  notifier.notify
    title: 'Error running Gulp'
    message: err.message
  gutil.log err
  @emit 'end'

gulp.task 'build', ['minify'], ->
  generateSass()
  generateStylus()
  # minifyJs()

gulp.task 'deploy', ['build'], ->
  exec 'deploy .', (error, stdout, stderr) ->
    console.log 'result: ' + stdout
    console.log 'exec error: ' + error  if error isnt null

gulp.task 'browser-sync', ->
  browserSync.init ["#{dest}/index.html"],
    server:
      baseDir: "#{dest}"
      middleware: [
        modRewrite ['^([^.]+)$ /index.html [L]']
      ]
    debugInfo: false
    notify: false


gulp.task 'default', ['watch']
