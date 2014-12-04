class Cors
  constructor: (@method, @url) ->
    throw "Error: Bad cors request method" if @method not in ['HEAD', 'GET', 'POST']
    throw "Error: You must provide url" unless @url?
    @xhr = new XMLHttpRequest()
    if 'withCredentials' of @xhr
      @xhr.open method, url, true
    else if typeof XDomainRequest != 'undefined'
      @xhr = new XDomainRequest()
      @xhr.open method, url
    else
      @xhr = null
    @xhr.ontimeout = -> throw "Error: Request timeout"
    @xhr.onerror = -> throw "Error: Request error"
    return @
  onload: (onload) ->
    @xhr.onload = onload
  send: (callback) ->
    @xhr.onload = =>
      callback @xhr.responseText
    @xhr.send()


class Blockchain
  WEBSOCKET_ADDRESS: 'wss://echo.websocket.org'
  API_ADDRESS: 'https://blockchain.info/q/'

  constructor: (@_notify) ->
    @_addresses = []
    @_isOpened = false
    @_connect()
  _connect: ->
    @_wss = new WebSocket @WEBSOCKET_ADDRESS
    @_wss.onopen = =>
      console.log "Opened connection to websocketq"
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
  getBalance: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'addressbalance/' + address
    request.send (data) ->
      callback data
  getReceived: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'getreceivedbyaddress/' + address
    request.send (data) ->
      callback data
