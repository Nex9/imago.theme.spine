BaseApp          = require('controllers/baseapp')

# Home           = require('controllers/home')
# Header         = require('controllers/header')

# Home           = require('controllers/home')
# Contact        = require('controllers/contact')

# Footer         = require('controllers/footer')

Nex.tenant       = 'tenant'
Nex.maintenance  = false


class App extends BaseApp

  logPrefix: '(App) index: '

  constructor: ->
    super

    # setup google analytics tracking
    Spine.Route.on 'navigate', (url) => _gaq.push ['_trackPageview', "#{url}"] if _gaq and not Spine.debug

    @routes

      '/': -> @log 'asdf'


  render: ->
    # @append @header          = new Header

    # @append @home            = new Home
    # @append @contact         = new Contact

    # @append @footer          = new Footer

    # @manager.add(
    #   @home
    #   @contact
    # )






module.exports = App
