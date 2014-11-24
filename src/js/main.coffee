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
  constructor: (@_posX, @_posY, @_color = 'transparent', @_destroy) ->
    @_posX ?= Math.random() * Document.getVisibleWidth()
    @_posY ?= Math.random() * Document.getVisibleHeight()
  setMotion: (angle = 90, @_speed = 5) ->
    @_angle = angle * (Math.PI / 180)
  getMotion: -> {angle: @_angle, speed: @_speed}
  update: ->
    @_move() if @_speed? and @_angle?
    @_draw()
  _move: ->
    @_posX += @_speed * Math.cos @_angle
    @_posY += @_speed * Math.sin @_angle
    console.log "Is on canvas?", @_checkIfOnCanvas()
    @_destroy() unless @_checkIfOnCanvas()
  _checkIfOnCanvas: =>
    Boolean @_posX + @_width < Document.getVisibleWidth() and @_posX > 0 and @_posY + @_height < Document.getVisibleHeight() and @_posY > 0
  _draw: ->
  _getContext: ->
    CanvasHolder.get().getContext()

class Rectangle extends Shape
  constructor: (@_posX, @_posY, @_width, @_height, @color = 'transparent', @_destroy) ->
    super @_posX, @_posY, @color, @_destroy
  _draw: ->
    ctx = @_getContext()
    ctx.fillStyle = @_color
    ctx.fillRect @_posX, @_posY, @_width, @_height
    ctx

class Image extends Shape
  constructor: (@_posX, @_posY, @_width, @_height, @_image, destroy) ->
    super @_posX, @_posY, @_width, @_height, destroy

class Rocket extends Image

class Galaxy
  constructor: ->
    # console.log "Galaxy constructor fired!"
    @_starsAmount = 400
    @_visibleStarsAmount = 0
    @_starIndex = 0
    @_stars = []
    @_boostController = new BoostController
  addSpeedBoost: (value, time) -> @_boostController.addSpeedBoost value, time
  setStars: (@_starsAmount) ->
  getStars: -> @_starsAmount
  update: ->
    # console.log "Updating"
    @_addNewStars()
    @_updateStars()
    @_boostController.timeTick()
  _addNewStars: =>
    console.log @_visibleStarsAmount
    for i in [@_visibleStarsAmount...@_starsAmount]
      @_stars[@_starIndex] = @_createStar @_starIndex
      console.log "Star added on index", @_starIndex
      @_starIndex++
      @_visibleStarsAmount++
    @_stars
  _createStar: (starIndex) ->
    width = Math.round (Math.random() * 5) + 1
    height = width
    posX = Math.round Math.random() * (Document.getVisibleWidth() - width)
    posY = Math.round Math.random() * (Document.getVisibleHeight() - height)
    star = new Rectangle posX, posY, width, height, '#ffffff', ->
      console.log "Star destroy event fired!", starIndex
      @_removeStar starIndex
      @_visibleStarsAmount--
    star.setMotion()
    star
  _removeStar: (starIndex) -> delete @_stars[starIndex]
  _updateStars: ->
    for star in @_stars
      do (star) ->
        star.update()

class CanvasHolder
  instance = null

  class Canvas
    constructor: ->
      console.log "Canvas constructor fired!"
      @_element = document.createElement 'canvas'
      @_element.setAttribute 'id', 'space'
      document.body.appendChild @_element
      @_ctx = @_element.getContext '2d'
      @_setFullscreen()
      @_elements =
        galaxy: new Galaxy
    getContext: -> @_ctx
    update: ->
      # @clear()
      element.update() for name, element of @_elements
    _setFullscreen: ->
      console.log "Setting fullscreen", Document.getVisibleWidth(), Document.getVisibleHeight()
      @_element.setAttribute 'width', Document.getVisibleWidth()
      @_element.setAttribute 'height', Document.getVisibleHeight()
    clear: -> @_ctx.clearRect 0, 0, Document.getVisibleWidth(), Document.getVisibleHeight()

  @get: -> instance ?= new Canvas

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
  @canvas = null
  @initialize: ->
    console.log "Initialized"
    @canvas = CanvasHolder.get()
    setInterval @mainLoop, 1000 / @FPS
  @mainLoop: ->
    Main.update()

  @update: ->
    @canvas.update()

Main.initialize()
