define ['underscore', 'backbone', 'bacon'], (_, Backbone, Bacon) ->

  BackBacon = {}
  for key, value of Backbone
    BackBacon[key] = value unless key == 'Model' || key == 'View'

  BackBacon.EventStream =
    asEventStream: (eventName, eventTransformer = _.identity) ->
      eventTarget = this
      new Bacon.EventStream (sink) ->
        handler = (args...) ->
          reply = sink(new Bacon.Next(eventTransformer args...))
          if reply == Bacon.noMore
            unbind()

        unbind = -> eventTarget.off(eventName, handler)
        eventTarget.on(eventName, handler, this)
        unbind


  class BackBacon.Model extends Backbone.Model
    _getSetterBusForProperty: (propertyName) ->
      @setBacons ||= {}
      return @setBacons[propertyName] if @setBacons[propertyName]
      
      model = @
      bus = new Bacon.Bus()
      @setBacons[propertyName] ||= bus
      bus.onValue (v) -> model.set propertyName, v
      return bus

    plugStream: (propertyName, stream) ->
      bus = @_getSetterBusForProperty(propertyName)
      bus.plug(stream)

    setBacon: (propertyName, baconProperty) ->
      @plugStream(propertyName, baconProperty)

    getBacon: (attribute) ->
      @getBacons ||= {}

      @getBacons[attribute] ||= (
        @asEventStream("change:#{attribute}", (_, value) -> value)
      ).toProperty(@get(attribute))

  class BackBacon.View
    constructor: (el, model) ->
      @el = $(el)
      @bindings ||= {}
      @streams = {}
      @model = model
      @createViewBindings()

    createViewBindings: =>
      @createViewBinding(binding) for binding, __ of @bindings

    createViewBinding:(name) =>
      # FIXME: Model should cache it's own streams
      stream = (@streams[name] ||= @model.getBacon(name))
      
      # FIXME: this is not a live selector I don't think?
      found = @el.find("[data-yield=#{name}]")
      el = @el
      stream.onValue (v) -> el.find("[data-yield=#{name}]:input").val(v)
      stream.onValue (v) -> el.find("[data-yield=#{name}]:not(input)").text(v)
      
      updateStream = @el.asEventStream("change", "input[name=#{name}]")
                        .map( (ev)->$(ev.currentTarget).val() )
                        .map( parseFloat )
      @model.setBacon name, updateStream

  class BackBacon.Collection extends Backbone.Collection
    model: BackBacon.model

  
  _.extend BackBacon,                      BackBacon.EventStream
  _.extend BackBacon.Model.prototype,      BackBacon.EventStream
  _.extend BackBacon.Collection.prototype, BackBacon.EventStream
  _.extend BackBacon.Router.prototype,     BackBacon.EventStream
  _.extend BackBacon.History.prototype,    BackBacon.EventStream
  _.extend BackBacon.View.prototype,       BackBacon.EventStream
      
  return BackBacon
