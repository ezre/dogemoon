class Blockchain
  constructor: (@_notify) ->
    @_addresses = []
    @_isOpened = false
    @_connect()
  _connect: ->
    @_wss = new WebSocket 'wss://echo.websocket.org'
    @_wss.onopen = =>
      console.log "Opened connection to websocket"
      @_isOpened = true
      for address in @_addresses
        @_watchAddress(address)
    @_wss.onclose = ->
      @_connect
    @_wss.onmessage = ->
      @_notify
    @_wss.onerror = =>
      @_wss.close()
      @_wss.connect()
  subscribe: (address) ->
    @_addresses.push address
    @_watchAddress address if @_isOpened
  _watchAddress: (address) ->
    @_wss.send JSON.stringify
      op: 'addr_sub'
      address: address