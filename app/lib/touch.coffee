{$} = require('spine')

# $.support.touch = ('ontouchstart' of window)
$.support.touch = !!navigator.userAgent.match(/Android|iPad|iPhone|iPod/i)

touch = {}

parentIfText = (node) ->
  if 'tagName' of node then node else node.parentNode

swipeDirection = (x1, x2, y1, y2) ->
  xDelta = Math.abs(x1 - x2)
  yDelta = Math.abs(y1 - y2)

  if xDelta >= yDelta
    if x1 - x2 > 0 then 'Left' else 'Right'
  else
    if y1 - y2 > 0 then 'Up' else 'Down'

$ ->
  $('body').bind 'touchstart', (e) ->
    e     = e.originalEvent
    now   = Date.now()
    delta = now - (touch.last or now)
    touch.target = parentIfText(e.touches[0].target)
    touch.x1 = e.touches[0].pageX
    touch.y1 = e.touches[0].pageY
    touch.last = now

  .bind 'touchmove', (e) ->
    e = e.originalEvent
    touch.x2 = e.touches[0].pageX
    touch.y2 = e.touches[0].pageY

  .bind 'touchend', (e) ->
    e = e.originalEvent
    if touch.x2 > 0 or touch.y2 > 0
      (Math.abs(touch.x1 - touch.x2) > 30 or Math.abs(touch.y1 - touch.y2) > 30) and
        $(touch.target).trigger('swipe') and
        $(touch.target).trigger('swipe' + (swipeDirection(touch.x1, touch.x2, touch.y1, touch.y2)))
      touch.x1 = touch.x2 = touch.y1 = touch.y2 = touch.last = 0
    else if 'last' of touch
      $(touch.target).trigger('tap')
      touch = {}

  .bind 'touchcancel', (e) ->
    touch = {}

if $.support.touch
  $('body').bind 'click', (e) ->
    target = $(e.target)
    # let browser load a new link...
    e.preventDefault() unless target.attr('target') is
      '_blank' or target.attr('href')?.match(/^mailto/) or   # has Blank attribute
      target.attr('href')?.match(/^tel/) or                  # is a tel link
      target.attr('href')?.match(/^http/) or                 # is an http link
      target.attr('type')?.match(/checkbox/) or              # checkbox
      target.attr('type')?.match(/checkbox|text/) or         # checkbox or text
      target[0].nodeName.match(/LABEL/)                      # label
else
  $ ->
    $('body').bind 'click', (e) ->
      target  = $(e.target)
      a       = target.closest('a')

      # let browser to load a new link ...
      unless target.attr('target') is '_blank' or           # blank atribute
        target.attr('href')?.match(/^mailto/) or            # mailto link
        target.attr('href')?.match('/api/') or
        target.attr('href')?.match(/^tel/) or               # tel link
        target.attr('href')?.match(/^http/) or              # http link
        target.attr('type')?.match(/checkbox/) or           # checkbox
        target.attr('type')?.match(/checkbox|text/) or      # checbox or text
        target[0].nodeName.match(/LABEL/) or                # label
        # el is NOT an anchor and closest a has external link
        (not target[0].nodeName.match(/A/) and a.attr('href')?.match(/^http/)) or
        # el is Not an anchor and closest a has traget _blank
        (not target[0].nodeName.match(/A/) and a.attr('target') is '_blank')
          # console.log 'default prevented'
          e.preventDefault()
      target.trigger('tap')

types = ['swipe',
         'swipeLeft',
         'swipeRight',
         'swipeUp',
         'swipeDown',
         'tap']
for m in types
  do (m) ->
    $.fn[m] = (callback) ->
      this.bind(m, callback)
