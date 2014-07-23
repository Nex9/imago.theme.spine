class Maintenance extends Spine.Controller
  @include Nex.Panel
  logPrefix: '(App) Maintenance: '
  className: 'maintenance active'

  constructor: ->
    super
    @html require('views/maintenance')



module.exports = Maintenance
