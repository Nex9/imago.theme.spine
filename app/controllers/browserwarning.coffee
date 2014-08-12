class BrowserWarning extends Spine.Controller
  logPrefix: '(App) BrowserWarning: '

  className: 'browserwarning active'

  constructor: ->
    super
    @log bowser
    @html require('views/browserwarning')





module.exports = BrowserWarning
