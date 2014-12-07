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


class CryptoChain
  WEBSOCKET_ADDRESS: ''
  API_ADDRESS: ''
  constructor: () ->
      @_addresses = []
      @_isOpened = false
      @_messageListeners = []
  connect: (callback) ->
    @_wss = new WebSocket @WEBSOCKET_ADDRESS
    @_wss.onopen = =>
      console.log "Opened connection to websocketq"
      @_isOpened = true
      for address in @_addresses
        @_watchAddress(address)
      callback()
    @_wss.onclose = ->
      @connect
    @_wss.onmessage = (event) =>
      for msgListener in @_messageListeners
        msgListener event
    @_wss.onerror = =>
      @_wss.close()
      @_wss.connect()
  subscribe: (address, callback) ->
  addMessageListener: (callback) -> @_messageListeners.push callback

class Dogechain extends CryptoChain
  WEBSOCKET_ADDRESS: 'wss://ws.dogechain.info/inv'
  API_ADDRESS: 'https://dogechain.info/api/v1/'
  subscribe: (address, callback) ->
    @_addresses.push address
    @_wss.send JSON.stringify
      op: 'addr_sub'
      addr: address
    @addMessageListener callback if callback?
  getBalance: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'address/balance/' + address
    request.send (data) ->
      callback data
  getReceived: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'address/received/' + address
    request.send (data) ->
      callback data


class Blockchain extends CryptoChain
  WEBSOCKET_ADDRESS: 'wss://echo.websocket.org'
  API_ADDRESS: 'https://blockchain.info/q/'
  subscribe: (address, callback) ->
    @_addresses.push address
    @_wss.send JSON.stringify
      op: 'addr_sub'
      address: address
    @addMessageListener callback if callback?
  getBalance: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'addressbalance/' + address
    request.send (data) ->
      callback data
  getReceived: (address, callback) ->
    request = new Cors 'GET', @API_ADDRESS + 'getreceivedbyaddress/' + address
    request.send (data) ->
      callback data
