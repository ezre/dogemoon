class BTCqrcode
  _protocol: 'bitcoin'
  _width: 200
  _height: 200
  constructor: (@_address = '1moonuxU6PAFEpYSegfDAKwqnF6CFZiWn', @_amount = 0.002) ->
    @_qrcode = new QRCode document.getElementById('qrcode'),
      text: @_getCode(),
      width: @_width,
      height: @_height
  _getCode: -> "#{@_protocol}:#{@_address}?amount=#{@_amount}"
  setAmount: (@_amount) ->
    @_qrcode.makeCode @_getCode()

class AmountInput
  constructor: (@_amount, @_onChange) ->
    @_input = document.getElementById 'calc'
    @_input.value = @_amount
    @_input.onkeyup = =>
      @_onChange parseFloat(@_input.value), @_numberFormat(100000000 * parseFloat @_input.value)
    @_input.onkeyup()
  _numberFormat: (n, c, d, t) ->
    c = if isNaN(c = Math.abs(c)) then 0 else c
    d ?= "."
    t ?= " "
    s = if n < 0 then "-" else ""
    i = parseInt(n = Math.abs(+n || 0).toFixed c) + ""
    j = if (j = i.length) > 3 then j % 3 else 0
    return s + (if j then i.substr(0, j) + t else "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + ( if c then d + Math.abs(n - i).toFixed(c).slice(2) else "");

class ProgressBar
  MAX_DISTANCE: 384400000
  HEIGHT: 567
  SATOSHI_IN_BTC: 100000000

  constructor: ->
    @_distance = 0
    @_futureProgress = 0
    @_progressBar = document.getElementById 'progressbar'
    @_progressBar.style.height = @HEIGHT + 'px'
    @_progress = document.getElementById 'progress'
    @_futureProgressBar = document.getElementById 'futureprogress'
    @_textProgress = document.getElementById 'textprogress'
  addDistance: (distance) ->
    @_distance += parseFloat distance
    @_progress.style.height = Math.round(@HEIGHT * @_distance / @MAX_DISTANCE) + 'px'
    @_update()
  setFutureProgress: (amount) ->
    @_futureProgress = amount * @SATOSHI_IN_BTC
    futureProgressHeight = Math.min(Math.round(@HEIGHT * @_futureProgress / @MAX_DISTANCE), @HEIGHT - @HEIGHT * @_distance / @MAX_DISTANCE)
    @_futureProgressBar.style.height = futureProgressHeight + 'px'
    @_futureProgressBar.style.top = '-' + futureProgressHeight + 'px'
    @_textProgress.style.top = '-' + (futureProgressHeight + 3) + 'px'
    @_update()
  _update: ->
    console.log @_distance, @_futureProgress, @MAX_DISTANCE
    @_textProgress.innerHTML = Math.min(Math.round(100 * (@_distance + @_futureProgress) / @MAX_DISTANCE), 100) + '%'

class UI
  constructor: ->
    @_elements =
      meters: document.getElementById 'meters'
      qrcode: new BTCqrcode
      progressBar: new ProgressBar

    @_elements.input = new AmountInput 0.002, @_updatePrice
  _updatePrice: (value, price) =>
    console.log "Change"
    @_elements.meters.innerHTML = price
    @_elements.qrcode.setAmount value
    console.log "VALUE", value
    @_elements.progressBar.setFutureProgress value
  getProgressBar: -> @_elements.progressBar
