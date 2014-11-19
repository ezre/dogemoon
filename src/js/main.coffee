class Blockchain
  wssConnect = ->
    addresses = []
    wss = new WebSocket 'wss://ws.blockchain.info/inv'

  wssReconnect = -> wss.close()

  wssSubscribe = (addr) ->
    addresses.push addr
    wss.send JSON.stringify
      op: 'addr_sub'
      addr: addr


  wssConnect()
  wss.onclose = wssConnect
  wss.onopen = ->
    console.log 'open'
    fetchAddresses ->
      wssSubscribe a for a of labels

      setDefaultBadge()

  wss.onmessage = (ev) ->
    notifyNewTx processTx JSON.parse(ev.data).x

  wss.onerror = (e) ->
    console.log 'error', e
    # TODO: reconnect