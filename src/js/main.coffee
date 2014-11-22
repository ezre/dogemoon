class Document
  @getVisibleWidth: ->
    return window.innerWidth if typeof window.innerWidth is 'number'
    return document.documentElement.clientWidth if document.documentElement and document.documentElement.clientWidth
    return document.body.clientWidth if document.body and document.body.clientWidth
  @getVisibleHeight: ->
    return window.innerHeight if typeof window.innerHeight is 'number'
    return document.documentElement.clientHeight if document.documentElement and document.documentElement.clientHeight
    return document.body.clientHeight if document.body and document.body.clientHeight

class SpeedBoost
  constructor: (@_value, @_time, destroy) ->
  getValue: -> @_value
  setValue: (@_value) ->
  decreaseTime: ->
    destroy() if --@_time == 0

class BoostController
  constructor: ->
    @_boostIndex = 0
    @_boosts = []
    @_boostSum = 0
  getSpeedBoost: ->
    @_boostSum
  addSpeedBoost: (value, time = 300) ->
    boostIndex = @_boostIndex
    @_boosts[boostIndex] = new SpeedBoost value, time, ->
      @_removeSpeedBoost boostIndex
    @_boostIndex++
  _removeSpeedBoost: (boostIndex) ->
    delete @_boosts[boostIndex]
  _addSpeedBoostToSum: (value) ->
    @_boostSum += value
  _removeSpeedBoostFromSum: (value) ->
    @_boostSum -= value
  timeTick: ->
    boost.decreaseTime() for boost in @_boosts

class Shape
  constructor: (@_width, @_height, @_posX, @_posY, angle = 180, @_speed = 100, destroy) ->
    @_posX ?= Math.rand 0, Document.getVisibleWidth()
    @_posY ?= Math.rand 0, Document.getVisibleHeight()
    @_angle = Math.toRadians angle
    @_destroy = destroy
  move: ->
    @_posX += Math.cos @_speed
    @_posY += Math.sin @_speed
  checkIfOnCanvas: ->
    (bool)(@_posX > Document.getVisibleWidth() or @_posX + @_width < 0 or @_posY > Document.getVisibleHeight() or @_posY + @_height < 0)

class Galaxy
  constructor: ->
    @_starsAmount = 400
    @_stars = []
    @_boostController = new BoostController
  addSpeedBoost: @_boostController.addSpeedBoost
  setStars: (@_starsAmount) ->
  getStars: -> @_starsAmount
  update: ->
    @_drawNewStars()
    @_moveStars()
    @_boostController.timeTick()
  _drawNewStars: ->
    # for i in [@_visibleStarsAmount..@_starsAmount]
  _moveStars: ->

class Canvas
  constructor: ->
    @_element = document.createElement 'canvas'
    @_element.setAttribute 'id', 'space'
    document.body.appendChild @_element
    @_ctx = @_element.getContext '2d'
    @_setFullscreen()

  getGalaxy: ->
    @_galaxy ?= new Galaxy

  setFullscreen: ->
    console.log "Setting fullscreen", Document.getVisibleWidth(), Document.getVisibleHeight()
    @_element.setAttribute 'width', Document.getVisibleWidth()
    @_element.setAttribute 'height', Document.getVisibleHeight()

# class Blockchain
#   wssConnect = ->
#     addresses = []
#     wss = new WebSocket 'wss://ws.blockchain.info/inv'

#   wssReconnect = -> wss.close()

#   wssSubscribe = (addr) ->
#     addresses.push addr
#     wss.send JSON.stringify
#       op: 'addr_sub'
#       addr: addr

#   wss = wssConnect()
#   wss.onclose = wssConnect
#   wss.onopen = ->
#     console.log 'open'
#     fetchAddresses ->
#       wssSubscribe a for a of labels

#       setDefaultBadge()

#   wss.onmessage = (ev) ->
#     notifyNewTx processTx JSON.parse(ev.data).x

#   wss.onerror = (e) ->
#     console.log 'error', e
#     # TODO: reconnect

class Main
  @FPS = 60
  @initialize: ->
    console.log "Initialized"
    @canvas = new Canvas()

    setInterval @mainLoop, 1000 / FPS
  @mainLoop: ->
    @draw()

  @draw: ->
    # @canvas.getGalaxy().

Main.initialize()
