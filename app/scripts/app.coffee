define ['underscore', 'backbone', 'bacon'], (_, Backbone, Bacon) ->
  
  Backbone.Model.prototype.setBacon = (propertyName, baconProperty) ->
    model = this
    baconProperty.onValue (value) ->
      model.set propertyName, value

  Backbone.Model.prototype.getBacon = (attribute) ->
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
    
  model1 = new Backbone.Model({ value: 10 })
  model2 = new Backbone.Model({ value: 2 })
  model3 = new Backbone.Model({ result: 0 })
  
  model1Value = model1.getBacon("value")
  model2Value = model2.getBacon("value")
  model3.setBacon "result", model1Value.combine(model2Value, (a,b) -> a+b)

  result = model3.getBacon "result"
  result.log()

  setInterval (-> model1.set({ value: model1.get("value") + 1 })), 1000
