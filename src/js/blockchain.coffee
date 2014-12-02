class Blockchain
  constructor: (@_notify) ->
    @_addresses = []
    @_connect()
  _connect: ->
    @_wss = new Websocket 'wss://ws.blockchain.info/inv'
    @_wss.onclose @_connect
    @_wss.onmessage @_notify
    @_wss.onerror ->
      @_wss.close()
      @_wss.connect()
  subscribe: (addr) ->
    @_addresses.push addr
    @_wss.send JSON.stringify
      op: 'addr_sub'
      addr: addr
