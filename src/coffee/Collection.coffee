'use strict'

@Collection = ->
  @currentItemIndex = 0
  @transitionSpeed  = .15

  # return `false` so Collection.prototype is used
  false

$.extend @Collection.prototype,
  _attributes:
    align         : 'right'
    $collection   : []
    selector      : ''
    collectionName: ''

  attributes: ->
    @_attributes

  get: (prop) ->
    return unless prop

    @_attributes[prop]

  init: ->
    $collection = @_attributes.$collection = $(@_attributes.selector).children()
    $collection.css('visibility','hidden').first().css('visibility','visible')
    $collection.addClass "collection_item collection_item__#{@_attributes.align}"

    @_attributes.$collection.each (i,el) ->
      $el = $ el

      $el.css 'background-image', "url(#{$el.data 'image'})"

  next: (e) ->
    TweenMax.to(@_attributes.$collection.eq(@currentItemIndex), @transitionSpeed, {autoAlpha:0})

    if @currentItemIndex >= @_attributes.$collection.length - 1
      @currentItemIndex = 0
    else
      @currentItemIndex++

    TweenMax.to(@_attributes.$collection.eq(@currentItemIndex), @transitionSpeed, {autoAlpha:1})

  prev: ->
    TweenMax.to(@_attributes.$collection.eq(@currentItemIndex), @transitionSpeed, {autoAlpha:0})

    if @currentItemIndex <= 0
      @currentItemIndex = @_attributes.$collection.length - 1
    else
      @currentItemIndex--

    TweenMax.to(@_attributes.$collection.eq(@currentItemIndex), @transitionSpeed, {autoAlpha:1})

  set: (prop, val) ->
    return unless prop

    if typeof prop is 'object'
      $.extend @_attributes, prop
    else
      @_attributes[prop] = if val then val else null

    @

