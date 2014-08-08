require('lib/setup')
_ = require('underscore')

# Home           = require('controllers/home')

Asset          = Nex.Models.Asset
Setting        = Nex.Models.Setting

# Header         = require('controllers/header')

# Home           = require('controllers/home')
# Contact        = require('controllers/contact')

# Footer         = require('controllers/footer')

Maintenance    = require('controllers/maintenance')

Nex.debug      = window.location.host.indexOf(':') > 0
Nex.tenant     = 'tenantName'

maintenance    = false

Nex.data       = if window.location.host.indexOf('8080') + 1 then 'local' else 'online'

Spine.Model.host = if (Nex.debug and Nex.data is 'online') then "http://#{Nex.tenant}.imagoapp.com/api/v2" else "/api/v2"



class App extends Spine.Controller

  logPrefix: '(App) index: '

  events:
    'tap a' : 'onNavigate'

  constructor: ->
    super

    @models = Nex.Models

    # setup google analytics tracking
    Spine.Route.on 'navigate', (url) => _gaq.push ['_trackPageview', "#{url}"] if _gaq and not Spine.debug

    # bind window resize and scroll
    @window = $(window)

    @window.on 'resize', @onResizeStart
    @window.on 'resize', _.debounce (=> @window.trigger 'resizestop'),  200
    @window.on 'resize', _.throttle (=> @window.trigger 'resizelimit'), 150

    @window.on 'scroll', @onScrollStart
    @window.on 'scroll', _.debounce (=> @window.trigger 'scrollstop'),  200
    @window.on 'scroll', _.throttle (=> @window.trigger 'scrolllimit'), 150

    @window.on 'mousewheel', @onMouseWheelStart
    @window.on 'mousewheel', _.debounce (=> @window.trigger 'mousewheelstop'),  200
    @window.on 'mousewheel', _.throttle (=> @window.trigger 'mousewheellimit'), 150

    # Spine.Route.bind 'change', @setLanguage
    Spine.Route.bind 'change', @setBodyClass

    # clear body for app
    @el.empty()

    # fetch data
    @settings      = new $.Deferred()
    Setting.bind 'refresh', => @settings.resolve()

    @manager = new Spine.Manager

    $.when(
      @settings
    ).then(
      @appReady, @errorCallback
    )

    @routes

      '/': ->

      # '/*page': (params) ->
      #   @page.active(params.match[0])

    Setting.fetch()

  onResizeStart: (e) =>
    return if @resizeing
    @window.trigger 'resizestart'
    @resizeing = true
    @window.one 'resizestop', => @resizeing = false

  onScrollStart: (e) =>
    return if @scrolling
    @window.trigger 'scrollstart'
    @scrolling = true
    @window.one 'scrollstop', => @scrolling = false

  onMouseWheelStart: (e) =>
    return if @isMouseWheeling
    @window.trigger 'mousewheelstart'
    @isMouseWheeling = true
    @window.one 'mousewheelstop', => @isMouseWheeling = false

  appReady: =>
    @log 'appReady'

    # set default language
    language = window.navigator.userLanguage or window.navigator.language
    Nex.language = language.split('-')[0]
    Nex.country  = language.split('-')[1]

    options =
      history: true
      shim: false

    @render()

    Spine.Route.setup options


  setLanguage: (Route, path) =>
    path = path.split('/')
    Nex.language = path[1] if !!path[1]

  setBodyClass: (Route, path) =>
    path = '/home' if path is '/'
    classes = "#{path} #{@manager?.getActive()?.className or ''}"
    document.body.className = (classes.replace(/\//g, ' ')).trim?()

  onNavigate: (e) =>
    href = $(e.target).closest('a').attr('href')
    @navigate href if href and not href.match(/^http/)

  render: ->

    if maintenance
      @append @maintenance     = new Maintenance

    else
      # @append @header          = new Header

      # @append @home            = new Home
      # @append @contact         = new Contact

      # @append @footer          = new Footer

      # @manager.add(
      #   @home
      #   @contact
      # )



  goHome: =>
    @navigate '/'


# find a faster better solution
Spine.Manager.include
  getActive: ->
    for cont in @controllers
      return cont if cont.isActive()


module.exports = App