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
  setMotion: (angle = 90, @_speed = 0.05) ->
    @_angle = angle * (Math.PI / 180)
  getMotion: -> {angle: @_angle, speed: @_speed}
  update: ->
    @_move() if @_speed? and @_angle?
    @_draw()
  _move: ->
    @_posX += @_speed * Math.cos @_angle
    @_posY += @_speed * Math.sin @_angle
    @_reset() unless @_checkIfOnCanvas()
  _reset: ->
  _checkIfOnCanvas: =>
    Boolean @_posX < Document.getVisibleWidth() + @_width and @_posX > 0 - @_width and @_posY < Document.getVisibleHeight() + @_height and @_posY > 0 - @_height
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
  _move: ->
    @_posX += @_speed * Math.cos @_angle
    @_posY += Math.pow(@_width, 2) * @_speed * Math.sin @_angle
    @_reset() unless @_checkIfOnCanvas()
  _reset: ->
    @_posY = 0
    @_posX = Math.random() * (Document.getVisibleWidth() - @_width)

class Sprite extends Shape
  constructor: (@_posX, @_posY, @_width, @_height, destroy) ->
  _draw: ->
    ctx = @_getContext()
    ctx.drawImage @_image, @_posX, @_posY, @_width, @_height
    ctx

class Rocket extends Sprite
  constructor: (@_posX, @_posY, @_width, @_height, destroy) ->
    @_drawn = false
    @_image = new Image()
    @_image.src = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAYAAADDPmHLAAAKMGlDQ1BJQ0MgUHJvZmlsZQAAeJydlndUVNcWh8+9d3qhzTAUKUPvvQ0gvTep0kRhmBlgKAMOMzSxIaICEUVEBBVBgiIGjIYisSKKhYBgwR6QIKDEYBRRUXkzslZ05eW9l5ffH2d9a5+99z1n733WugCQvP25vHRYCoA0noAf4uVKj4yKpmP7AQzwAAPMAGCyMjMCQj3DgEg+Hm70TJET+CIIgDd3xCsAN428g+h08P9JmpXBF4jSBInYgs3JZIm4UMSp2YIMsX1GxNT4FDHDKDHzRQcUsbyYExfZ8LPPIjuLmZ3GY4tYfOYMdhpbzD0i3pol5IgY8RdxURaXky3iWyLWTBWmcUX8VhybxmFmAoAiie0CDitJxKYiJvHDQtxEvBQAHCnxK47/igWcHIH4Um7pGbl8bmKSgK7L0qOb2doy6N6c7FSOQGAUxGSlMPlsult6WgaTlwvA4p0/S0ZcW7qoyNZmttbWRubGZl8V6r9u/k2Je7tIr4I/9wyi9X2x/ZVfej0AjFlRbXZ8scXvBaBjMwDy97/YNA8CICnqW/vAV/ehieclSSDIsDMxyc7ONuZyWMbigv6h/+nwN/TV94zF6f4oD92dk8AUpgro4rqx0lPThXx6ZgaTxaEb/XmI/3HgX5/DMISTwOFzeKKIcNGUcXmJonbz2FwBN51H5/L+UxP/YdiftDjXIlEaPgFqrDGQGqAC5Nc+gKIQARJzQLQD/dE3f3w4EL+8CNWJxbn/LOjfs8Jl4iWTm/g5zi0kjM4S8rMW98TPEqABAUgCKlAAKkAD6AIjYA5sgD1wBh7AFwSCMBAFVgEWSAJpgA+yQT7YCIpACdgBdoNqUAsaQBNoASdABzgNLoDL4Dq4AW6DB2AEjIPnYAa8AfMQBGEhMkSBFCBVSAsygMwhBuQIeUD+UAgUBcVBiRAPEkL50CaoBCqHqqE6qAn6HjoFXYCuQoPQPWgUmoJ+h97DCEyCqbAyrA2bwAzYBfaDw+CVcCK8Gs6DC+HtcBVcDx+D2+EL8HX4NjwCP4dnEYAQERqihhghDMQNCUSikQSEj6xDipFKpB5pQbqQXuQmMoJMI+9QGBQFRUcZoexR3qjlKBZqNWodqhRVjTqCakf1oG6iRlEzqE9oMloJbYC2Q/ugI9GJ6Gx0EboS3YhuQ19C30aPo99gMBgaRgdjg/HGRGGSMWswpZj9mFbMecwgZgwzi8ViFbAGWAdsIJaJFWCLsHuxx7DnsEPYcexbHBGnijPHeeKicTxcAa4SdxR3FjeEm8DN46XwWng7fCCejc/Fl+Eb8F34Afw4fp4gTdAhOBDCCMmEjYQqQgvhEuEh4RWRSFQn2hKDiVziBmIV8TjxCnGU+I4kQ9InuZFiSELSdtJh0nnSPdIrMpmsTXYmR5MF5O3kJvJF8mPyWwmKhLGEjwRbYr1EjUS7xJDEC0m8pJaki+QqyTzJSsmTkgOS01J4KW0pNymm1DqpGqlTUsNSs9IUaTPpQOk06VLpo9JXpSdlsDLaMh4ybJlCmUMyF2XGKAhFg+JGYVE2URoolyjjVAxVh+pDTaaWUL+j9lNnZGVkLWXDZXNka2TPyI7QEJo2zYeWSiujnaDdob2XU5ZzkePIbZNrkRuSm5NfIu8sz5Evlm+Vvy3/XoGu4KGQorBToUPhkSJKUV8xWDFb8YDiJcXpJdQl9ktYS4qXnFhyXwlW0lcKUVqjdEipT2lWWUXZSzlDea/yReVpFZqKs0qySoXKWZUpVYqqoypXtUL1nOozuizdhZ5Kr6L30GfUlNS81YRqdWr9avPqOurL1QvUW9UfaRA0GBoJGhUa3RozmqqaAZr5ms2a97XwWgytJK09Wr1ac9o62hHaW7Q7tCd15HV8dPJ0mnUe6pJ1nXRX69br3tLD6DH0UvT2693Qh/Wt9JP0a/QHDGADawOuwX6DQUO0oa0hz7DecNiIZORilGXUbDRqTDP2Ny4w7jB+YaJpEm2y06TX5JOplWmqaYPpAzMZM1+zArMus9/N9c1Z5jXmtyzIFp4W6y06LV5aGlhyLA9Y3rWiWAVYbbHqtvpobWPNt26xnrLRtImz2WczzKAyghiljCu2aFtX2/W2p23f2VnbCexO2P1mb2SfYn/UfnKpzlLO0oalYw7qDkyHOocRR7pjnONBxxEnNSemU73TE2cNZ7Zzo/OEi55Lsssxlxeupq581zbXOTc7t7Vu590Rdy/3Yvd+DxmP5R7VHo891T0TPZs9Z7ysvNZ4nfdGe/t57/Qe9lH2Yfk0+cz42viu9e3xI/mF+lX7PfHX9+f7dwXAAb4BuwIeLtNaxlvWEQgCfQJ3BT4K0glaHfRjMCY4KLgm+GmIWUh+SG8oJTQ29GjomzDXsLKwB8t1lwuXd4dLhseEN4XPRbhHlEeMRJpEro28HqUYxY3qjMZGh0c3Rs+u8Fixe8V4jFVMUcydlTorc1ZeXaW4KnXVmVjJWGbsyTh0XETc0bgPzEBmPXM23id+X/wMy421h/Wc7cyuYE9xHDjlnIkEh4TyhMlEh8RdiVNJTkmVSdNcN24192Wyd3Jt8lxKYMrhlIXUiNTWNFxaXNopngwvhdeTrpKekz6YYZBRlDGy2m717tUzfD9+YyaUuTKzU0AV/Uz1CXWFm4WjWY5ZNVlvs8OzT+ZI5/By+nL1c7flTuR55n27BrWGtaY7Xy1/Y/7oWpe1deugdfHrutdrrC9cP77Ba8ORjYSNKRt/KjAtKC94vSliU1ehcuGGwrHNXpubiySK+EXDW+y31G5FbeVu7d9msW3vtk/F7OJrJaYllSUfSlml174x+6bqm4XtCdv7y6zLDuzA7ODtuLPTaeeRcunyvPKxXQG72ivoFcUVr3fH7r5aaVlZu4ewR7hnpMq/qnOv5t4dez9UJ1XfrnGtad2ntG/bvrn97P1DB5wPtNQq15bUvj/IPXi3zquuvV67vvIQ5lDWoacN4Q293zK+bWpUbCxp/HiYd3jkSMiRniabpqajSkfLmuFmYfPUsZhjN75z/66zxailrpXWWnIcHBcef/Z93Pd3Tvid6D7JONnyg9YP+9oobcXtUHtu+0xHUsdIZ1Tn4CnfU91d9l1tPxr/ePi02umaM7Jnys4SzhaeXTiXd272fMb56QuJF8a6Y7sfXIy8eKsnuKf/kt+lK5c9L1/sdek9d8XhyumrdldPXWNc67hufb29z6qv7Sern9r6rfvbB2wGOm/Y3ugaXDp4dshp6MJN95uXb/ncun572e3BO8vv3B2OGR65y747eS/13sv7WffnH2x4iH5Y/EjqUeVjpcf1P+v93DpiPXJm1H2070nokwdjrLHnv2T+8mG88Cn5aeWE6kTTpPnk6SnPqRvPVjwbf57xfH666FfpX/e90H3xw2/Ov/XNRM6Mv+S/XPi99JXCq8OvLV93zwbNPn6T9mZ+rvitwtsj7xjvet9HvJ+Yz/6A/VD1Ue9j1ye/Tw8X0hYW/gUDmPP8uaxzGQAAFVVJREFUeJztnXuUHVWVxn/7VN1H39vPPBqIBEMIGCCAElAePlBxZFREhBFGcQnqQkZlOTguHR8zOo4yqMxao874xhGF0VFQAXkMDCMKyhujiCYQICGEQB4knU73fVTV2fPHqcrtJP26nU7fW5V8a9WqvvdWVZ86+zt777PPPueIqrIPey9MqwuwD63FPgLs5fBbXYBmodYCu222YuKLlancLaAKIgIypSe0DWQv8gEEJ3gFbPydF5+jlpSoDZAqAmgUsvWPv0eDsNmW57GjkBejdjA3a85ayeexw0Oi1hoxZpJEENRG+J1ddBx4UDPlaDukgwBO3xJuHeC3p59CsHkT4udB7UR3Ji1ecebuDOC9iDnVhsG2OUuOvnH+OeddUTrhVb/0S2VsZcigqoiZuFJUMYUCud6+3X27liJdBBjcyn1vewPBlucRP+e+HxsjW/07gI8AL97+SICgzgH9fXQds/R/O08/91+6Xvby/xvl3kwjdQS49+zTJiKAxIcFjgMuB14V/5YI1QAo2EIhb+b1FCUKQ/LHnnD1nHd/6O+LCw55WqPIE5FoQlOTcicwa93AkU7eR4Hf4IQfxd958SE40XnVSk0GI4nyPb02XHbfO9Z9/H33b7ruv88Sz4swxl2bePujHSlHlghgcELuAH4EfAHI44TvMca7iggDW7Z5YRAYU+4KvSjaf+Bbl1/z7Fcu/UxUrUaICKrpl/QYyAoBEuH3ALcA5wAhTht449yHCNSDkKHhGoL11Rjr9/RGwzdf8+l1X/jk16Nq1QImqyTIAgESwXQANwCvBAKc1z8poYnA4FDFuRSqRqPI+LPmBMF9v75o3Rc/9R+qGqHqTeB0phJZIICHa/0/AF6BE36umQeICLVaQL0euOgeiIZhzuvpC4J77nj/hu997eMYE2Jt6iKnEyHtBPBwqv6jwFlMQfgJrFUq1XpCAAA0Cn2vtzccvOZ7lw78+rbX4Hkh1o5rUtKGNBMg6asfA3wu/nu3WmilWmenbrGoVeOXy2y+4stX1Deu70JEs+QPpJkAirPxX6XR6qcsGBEIghBrd4ouqhpy+VA3rV/w/Pe/8Q+IWFTTXG87IK0vktj9M3B2P+nqTRkiQhhZwsjuYAYAiCLP6+yylbtu++DwY8sXYozF2rTW3Q5I60u4rhl8gmkYG06gqkRRNJoaERWxBPWOLT+96hIa2if1SCMBPJwATgaOZxJ9/clC1TmDo4rWWs8rlbT2u3veUX/2mTkYE2Gnlk7QTkgjARK8Kz5POCTYDKwdU6EInm8ZHOjb+qv/eTOAqqa+R5A2AgjO3peA0+LvZuwdVC2Sy2nlwXveqtYixkwr+VqBtBEgKe+xwAtw6n/m3sGqkXxeorWrTgw2beiLewSpNgNpI0BS2SfF55kesxfxfLWDA7Oqj/35GABNeW8gbYVPDPSxLSuBSCRRRLh29THJNy0ryzQgbQRIbO7C+Dzj5XcZY4baqscPAxCRVI8QpWlwQwAVzysipn+PJGMIICY+xpCrGFFjkKA+f/oLMPNIEwFAlXDL5iK1ShdRjml3wKxCreLSSMbqDhoD1QpSHS4npZrWMswwUkUAUyiy/3s/KGsiI6ZQBGun1QJba9E5s9HuzngCyigQQYMQnTNXks9pRjoIIILGadj7n38Rq+9/CON5O4/c7TbUWnTuXOjpcuQa9SJcyLCQ3162NCMdBBiBcMtmGB4C358oLbx5WAuVIciZsQkAsXmwQNf0/v8WIHUEEM9zdtiY6ScANJ49LjT1LT9B2rqB+zDN2EeAvRz7CLCXYx8B9nLsI8Bejn0E2MuRum7gVKGqbiBnZN6/ArjvdkkE3UuQeQJYVQShWMjjeYYoskSRCyH7nocxQhBE1IJg2iOLaUCmCWCtUizmsZHl0SfWsOKJp3jmuU0MV6qICN2dJebP6+fwRQuYP6+fej3YdV5AxpFZAqgq5VKR5Y+v5sbb7+bx1WuphxYjjfEjBe5Z9mfKxbs55ohD+ctXn8CB8/bfq0iQSQKoQrGY55Y77uW6W+/EKhRzHnlCwKCej6AQhYAL7d/90CM8suIJLrnwrznlxKVs3TaEN2FIOP3IHAGsVUodBW68/W5+dsuvKHeWMWEN6+XRg4+DuYdARzeqFrZtgnXL4Zk/01nwqdZDLv3qlRRyeU5YuoRtQ8OYjJMgUwSw1lLqKLLsTyu5/ra76OwsQ72CnXc4vOTN0N3vVhaz1g3m9B8CC18Kz60keuCn5IY3UVfD5d+8mi9/9sPMnd1LEISZ7iFkit6e51Gp1rjhtt/g+T4EVfTAo+Dl50O5D6rboF6BsA5BDerD7thvEZzyXmxpNkVf2PD8Fq7+6S3kc7nM9wwyQwBrLcVCnt//aSVr1q2n4AlamgVLz3StPqyD8eJ8v2SRpzj/rzYE5Vlw3JmE1lLu6OCu+//Ak2vWUSjkM02CzBAAXNbQwyuecEIN67DoBCj1uL9lnFc1ntME/YvggMX4GjAwOMRDf1hOIZ/H7iNA+8PzhOFKlWfXbyJnQHNF2O9QiILxhT8SIrD/YlBFjPDYqjVYa9Od+D8BMkEAt46koVYPGKrU3EvlS1Dsajh8E0KcqeichRoPg7B5YJBotPUCMoRMEADUTRpQbaSJJUtBNo1kodH4eenO+p4QmSCAiGBVyedzdBQLbvpQveqcO5ls7qC6aysDYEMUpaerjLcHso/bCZkgAEAUxwD6Z/cRWZD6MGx4EvwcTbXi5x5DxA0iHTx/HsaYTOuAzBAAVTzPcPhhC1ws3/Ph8Xtdv3+iDGK1kCvC5rWw9hEik6dcLHDsUS8iCALMPh+g/SHGUKvVecmRhzJ3dg+BGmTLWvjDzZArORJYGxMhPlTBRuAXXFfxwZ/h2ZChSo2lRy/msIUHUanV9zmBaYAAYWjp7S5z2ikvo1qrYQoleOy3cP9PnKCLZfDzYHx35AqupzD0PNz5n8im1YTiUy4WOO+tp7kEkla/2B5GpsYCjBGGKzVOPv5oVj/9HL/87UN0d3eiK+9GNzwJBx8PcxdAodOp/eEBWLcCVj2AqQ9j/SLDQ0N85KLzWLzohWzdNpz5EcFMEcBBCIKAc978GkSEO+5+iHyhQH5oEyy7Ac0VnMpXhaCKRAHkClQjgajOxRf8Fae/7mQG9wLhQwYJIOKGhFUtb3/LqSw86ABu/uW9PLvxeUQMXj1EgkYeQGQNnoYsWvAC3vTak3jlCS9haLiW+WHgBJkjALi4gALVWp2TjjuKJYsX8vDyJ1i+cjXPbdxMpVrDiFAudfCC/eawZPFCDj/0hYgI24Yq9PXmx1suLlPIJAEgjuWJMDRcIZ/LcfJxR3HS0iVUa3WCeNu5Qj5HIZ/DqlKr1QmjiL6evaPlJ5h5Aqi6xRdEaCZAo/HGUWMu3DAGjHE7wQ0NVwDBGCGfd2tLW2vd9yKY+GgKI0PPU0EbmJmZJ4CIm+Ld7G3x2S+VplTpI236yNDulG19TMi0TxOfOQLEFVZdt5bKU6uR3IT7/u14O4pYy6D4InticYhmoAq+L7ptqwlWPgqe11x53P3kFi+ZUmOYTswYAdRGiOez7vprePSyfyI/ey4aBZN/gFucSTj0iLr52KVGoxbu66gWyefDcPVKu/GD7/KkXB5/RZGREIEwxPT0Mff7P0e6uhvapAWYcRMguTx+Zyd+uYzGadmTu1E8CoVQBwc+Gw1u7aazOyIKvRmvOGuNKZe1vuyBoysP3PUiM7d/RbyNzOQYGRNASqW2MB8tcwKTY5LIIRJg7YeBSxBJNoFsBQTjWa1W+od/ce0NdHafhLUbaWxdN8Hd4rRFm0w+ab0bOjF83GZQ5wD/itskqrVNR9XgeRGefyiqPweK8S+tb9JNot0J4OME/krgShrbv7a+olU90BC3ccUPaOxi0vqyNYF2JkCyJdwRwM+AQvx9O1Vwop3OBr7CNOxdNNNoVwIYXGXOBa4DZsWf27G8ORxRL8ZtUR8yxb0LW4F2rNCRW8FeByyi/VtWoq2+BLydxta1bY92I4DQ8KavBk7EVWw7Cx9cuZOt7L4HvBpX7rYnQbsRIOlP/ztwJilqSTQ0Vw64FjiSFJC3nQiQ2NKPAR8gZbY0RuK79OHM1360r+8CtE/BEm/6ncBlpKDljINEix0CXA+UaeONJtuBAElf/1Tgu7RTX3/qSJzClwI/pLG7Wdu9U6sJkFTUEuAnNFp921XUFJAQ+3Tga7RpT6aVBEjs5TzgBqCXRjQtK0hI8DfAJ2lDv6ZVlW1warET5ywtoE1byDQg0XKfA86nzXo2rSBAMv1WgR8Bx5Fup28iJDGCCPgO8Be0UYygFQRIVP83gDfSRpWxB5GQ3gA/Bo6BeM26FmOmC5AI/x+B97F3CD9BEuHswXUP59MGPs9M/vMkVHo28E9kW+2PhcQUHARcQxuMcM4kAZKXPJZGPngWunvNInGAj8QFiVqaGtQK9eMS9PduCFClDdafaZUTuA9tUg9tUYgmoCAtzAcfARFF2qQsu4G0EMCSJIPayGvppBBIUrtFg7oXZyinlgjtToCkcg0iPjbaTE/flXSUtqKTXf9vmiGiGoaYvlmr/P3m/YYwNIgkvZmINrDrzaBdCRDR6CN7wGrgM0T2KO3pu4BiRxjn1c98ZYtYrQyTO/LFK3o/9tmXa63yRkR+EZclGcUMW1K2KaCdgjDJjswejfjAA8A3cdGzrQBE0RzCUOPpFWojK26O5mTXgx0LEk/21e3HSFjFguIZY7FWqNfyGAMiNwE3AUtxwa234YI94IicRADbEu1AAMVVlE9D8DfhhlBvotGScqhGeL6lp7ervmG9KeYMHeVOImuJomhKfUvFzVsEt45UIee7NQO2z9xxm075vjEiwnClZqJSGent7pCNZVDNxeV/ELgQ+DxwAfBuXLQPHLETDdFWaCUBEvvuxeUYxOUEfBO4b8R1LoKoGuDnkOfXb9X/+vaph519rv/gus1y5423q0L/U2ufvdKIKezyX8aBquJ5PgcsOgrj+agq+dwqfN9PNIBVML4xjx52UP9FkbXyupOP0f6Hfk395qe3DA0OILl8GF+cJHw4cwX/hpvNdCEu+JWgrUY9W0EAi0iESD524p7GZdJeAayKr0kqM2Kkh53LI5s2hPaH37nz4HdfwC3L13Dlj65jv/65Z1rVAk1Wrqri+Xkq5QPx/PwI9b/9kmTUcv6yR9cuH6pU1r30uCX033krA7fejNc3CymWNN5OPlEZJj624Mj8beBNwPuB1yPix+sKNDEzds9hxgmg1pY1CDwNgwc1Cr+LS5naHP/s0fAFRofx0FLZ08jie77p6eqMOsulC8NmZhonZYkJUMj5eHGr38mMJA5dhzFyvm/0i57n+1ooh9LVrVLssIS7THG38ZHY/gg3+HM9cAIi7yMMzyEM5zZd4D2AmSSABfCKHffnZs1+Z66372qNoqSt+TRMwrgQY7CeF4lnjA0rQaQ6z1r7inhRp6acLVVFrO7g+I3iuktc+rdEymW2uqUuOVXT2YXp7BpvYYjEt4EGse9B5B7C8PPS3XMuIi3vKcwYAcTzLcCB55x37bwzzo43cVAfV0lNNF8lUqCzburf+rb1i92vF8KiEaqAnyhtAQ8Z3y9UVTyjeGLxxDJS/Nro0yuKNXC0V+g6rHLDGSsKrzvT9F98oxWNQCZlcRIiJKZtpYh8TkrluHJaR4QZNwEmXzAmXxAa0b3mnwHARlut1czWevfFuZz1IhvbfhvrbRFUZVydkpiA2bVOvCjeGygWkcF6xiq6/bPmKpQvjKoDfyd5Maazy0rz2d4j/YTEx2kpWuME7lYoV1FEULELemrF175ww4+7OrjeugZsKKlGKvUXFYfe01MKFoY9KGYsKSliPPr2H8aIhwrIoKgZ1mC17v/dwXxptT9sSxpJaFCpSWlVV66OtSYSVbChW3N4KnUAe+kKIbDbL+4hqoHPGYeuq561YMNlKvGeAAr2IItslsv9rcxjfmSZq2aiEXcbPhyXC6iBecLzw9A7PjpQL5MtsloGBDwQ41Mb2kKoec1v33ms9ULcHbRDIGjKqFuhWvd9jC84ZR2yWq+iLufasqrtMCJbJ/EgicMHCviI9BnMWlkqT+kyNbwcWCEWT/HD8Y1K+pBqAghgRENEPdAAuATLuYgG0mtzxtNJTsoasc+QAt1WzAYvJKJXIq5COBGoSwY3j2nbGHUTSJItDwL+GbAYfDqY2ow8pwWgoD5KgPBi3OIPLU/g3BPIwgslOXYfIMmxM4ganfp4nIC6PoXnthnnb3GTWJLBncwg7QRIulIFXLaxi8lPx25v7v5Eu8wDXhv/0jZx/OlAFgigwOHAwfF3BgsSSuPXZpHcD8TRIcXNXs4c0k6ApPyLceK224U+zNSUtQB1oLb96cmsniPiK9pjhcdpQtoJkGC/+KzJTHwZNM1b7NHvTZ4wKz7vI0AbYsfurAGqIFulMQwzGRggANksDdeygZG2PzOOYFYIMLDDp7j7J+uNm4w9mbdMWv9GM1L9J78ADMXnqXoWbYm0EyARxKr43HgfA9RA1pmJ3zLu+8sWQTbtojWSv1bv8j8ygLS/TCKcP+HcvobiToQ6II4E3k53jHyCDzIoyNpxq+N38Tkz6h/ST4AkOvcM8BA7ZxMlan2DIE/HrzqSCIIT/vOCPGXGihwmd9w+4s7MIO0EgMY7XMNY9jkWsnnSINtiB88H6iBrTKPl7yr8ZODnYWAZbTKGP53IAgESgfwQl4i5q9+fxPcrgqwyyFNO6OYJr+Hxjw3BJXdmcj2DLBAgybdfD3ydsVppkrhtXPdQNkmDGKMjMS9rcHsVZK71QzYIAA1hfQlYR2M1ktGRmAAYz6Inmb2fALYxWmQgA8gKARL3bTNu6Hbi1jq+KJO1i24ArqKxtEvmkBUCQGNSyLW4aWU5XBhoKs/xcbGF95CxwM/OyBIBoDG59EPArTRPgoREW4C3ABtIBpkyiqwRIBm6jYCzgDtokGCiVpx4+ZuANwC/ZyJfIgPIGgGg4bxtwy1EeS2N9XlHs+PJjCQfWA6cAtwdf86k3R+JlBNAxjqsm3okwyBng3wKJHTTeCSKDxufTfz9VSAngfwx/hyO8/zWvO4eQKqzgrGBO4BRNHyiCQQ3Z/823GYUr97pukeAT+M0BTQmdI4CdRPGNTuKIcUEEKTY5/40PmOY+MQn8HBrDrwGOAO4BLeKx9dw3bwKDXs/TvzAd8L3O6bpHVoPSW+mu6L1QZrooSWBnNFumHw/XxXxi+AVJ742BUgxAaaMpKUngeDUrew1nfh/GRdKZ/q82QEAAAAASUVORK5CYII="
    @_boundries =
      xMin: @_posX - 5
      xMax: @_posX + 5
      yMin: @_posY - 30
      yMax: @_posY + 30
    @_speed = 0.1
    @_angle = Math.random() * 360
    @_image.onload = =>
      @_draw()
      @_drawn = true
  _move: ->
    if @_posX + @_speed * Math.cos(@_angle) < @_boundries.xMin
      @_angle = Math.random() * 180 + 270
    if @_posX + @_speed * Math.cos(@_angle) > @_boundries.xMax
      @_angle = Math.random() * 180 + 90
    if @_posY + @_speed * Math.cos(@_angle) < @_boundries.yMin
      @_angle = Math.random() * 180 + 180
    if @_posY + @_speed * Math.cos(@_angle) > @_boundries.yMax
      @_angle = Math.random() * 180
    @_posX += @_speed * Math.cos @_angle
    @_posY += @_speed * Math.sin @_angle
  update: ->
    @_move()
    if @_drawn
      @_draw()

class Galaxy
  constructor: ->
    @_starsAmount = 50
    @_visibleStarsAmount = 0
    @_starIndex = 0
    @_stars = []
    @_boostController = new BoostController()
    @_addNewStars()
  addSpeedBoost: (value, time) -> @_boostController.addSpeedBoost value, time
  setStars: (@_starsAmount) ->
  getStars: -> @_starsAmount
  update: ->
    @_updateStars()
    @_boostController.timeTick()
  _addNewStars: =>
    if @_visibleStarsAmount < @_starsAmount
      for i in [0..@_starsAmount]
        @_stars[@_starIndex] = @_createStar @_starIndex
        @_starIndex++
        @_visibleStarsAmount++
    @_stars
  _createStar: (star_id) ->
    width = Math.round (Math.random() * 3) + 1
    height = width
    posX = Math.round Math.random() * (Document.getVisibleWidth() - width)
    posY = Math.round Math.random() * (Document.getVisibleHeight() - height)
    star = new Rectangle posX, posY, width, height, '#ffffff', =>
      @_removeStar star_id
      @_visibleStarsAmount--
    star.setMotion()
    star
  _removeStar: (starIndex) ->
    delete @_stars[starIndex]
  _updateStars: ->
    for star in @_stars
      do (star) ->
        star.update() if typeof star != 'undefined'

class CanvasHolder
  instance = null

  class Canvas
    constructor: ->
      @_element = document.createElement 'canvas'
      @_element.setAttribute 'id', 'space'
      document.body.appendChild @_element
      @_ctx = @_element.getContext '2d'
      @_setFullscreen()
      @_elements =
        galaxy: new Galaxy()
        rocket: new Rocket Document.getVisibleWidth() / 2 - 64, Document.getVisibleHeight() - 228, 128, 128
    getContext: -> @_ctx
    update: ->
      @clear()
      element.update() for name, element of @_elements
    _setFullscreen: ->
      @_element.setAttribute 'width', Document.getVisibleWidth()
      @_element.setAttribute 'height', Document.getVisibleHeight()
    clear: -> @_ctx.clearRect 0, 0, Document.getVisibleWidth(), Document.getVisibleHeight()

  @get: -> instance ?= new Canvas()

class Game
  @FPS = 25
  @canvas = null
  @initialize: ->
    console.log "Initialized"
    @canvas = CanvasHolder.get()
    setInterval @mainLoop, 1000 / @FPS
    ui = new UI
  @mainLoop: ->
    Game.update()

  @update: ->
    @canvas.update()

Game.initialize()
