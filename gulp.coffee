dest = 'public'
src = 'app'

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
    'node_modules/imago-gulp-spine/node_modules/jade/runtime.js'
    'node_modules/imago-gulp-spine/node_modules/commonjs-require-definition/require.js'
    'node_modules/imago-gulp-spine/node_modules/browser/browser.js'
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

configGulp =
  src     : src
  dest    : dest
  targets : targets
  paths   : paths

module.exports = configGulp
