define ['backbone', 'bacon'], (Backbone, Bacon) ->

  BackBacon = {}
  for key, value of Backbone
    BackBacon[key] = value unless key == 'Model' || key == 'View'

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
      #model = this
      #baconProperty.onValue (value) ->
      #  model.set propertyName, value

    getBacon: (attribute) ->
      @getBacons ||= {}

      @getBacons[attribute] ||= do =>
        model = this
        (new Bacon.EventStream (sink) ->
          handler = (model, value, options) ->
            reply = sink( new Bacon.Next( value ))
            if reply == Bacon.noMore
              unbind()
            
          unbind = -> model.off "change:attribute", handler
          model.on "change:#{attribute}", handler
          unbind
        ).toProperty(model.get(attribute))

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

      
  return BackBacon
