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

class UI
  constructor: ->
    @_elements =
      meters: document.getElementById 'meters'
      qrcode: new BTCqrcode
    @_elements.input = new AmountInput 0.002, @_updatePrice
  _updatePrice: (value, price) =>
    console.log "Change"
    @_elements.meters.innerHTML = price
    @_elements.qrcode.setAmount value
