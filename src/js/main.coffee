class Document
  @getVisibleWidth: ->
    return window.innerWidth if typeof window.innerWidth is 'number'
    return document.documentElement.clientWidth if document.documentElement and document.documentElement.clientWidth
    return document.body.clientWidth if document.body and document.body.clientWidth
  @getVisibleHeight: ->
    return window.innerHeight if typeof window.innerHeight is 'number'
    return document.documentElement.clientHeight if document.documentElement and document.documentElement.clientHeight
    return document.body.clientHeight if document.body and document.body.clientHeight

class Canvas
  constructor: ->
    @canvas = document.createElement 'canvas'
    @canvas.setAttribute 'id', 'space'
    document.body.appendChild @canvas
    @setFullscreen()

  setFullscreen: ->
    console.log "Setting fullscreen", Document.getVisibleWidth(), Document.getVisibleHeight()
    @canvas.setAttribute 'width', Document.getVisibleWidth()
    @canvas.setAttribute 'height', Document.getVisibleHeight()

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
  @initialize: ->
    console.log "Initialized"
    @canvas = new Canvas()

  @addResize

Main.initialize()
