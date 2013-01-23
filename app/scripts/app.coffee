define ['underscore', 'backbone', 'bacon', './BackBacon'], (_, Backbone, Bacon, BackBacon) ->

  todos
    
  ###
  model1 = new BackBacon.Model({ value: 10 })
  model2 = new BackBacon.Model({ value: 2 })
  model3 = new BackBacon.Model({ result: 0 })
  
  model1Value = model1.getBacon("value")
  model2Value = model2.getBacon("value")
  model3.setBacon "result", model1Value.combine(model2Value, (a,b) -> a+b)

  result = model3.getBacon "result"
  model1Value.log()
  model2Value.log()
  #result.log()

  setInterval (-> model1.set({ value: model1.get("value") + 1 })), 1000

  class MyOtherView extends BackBacon.View
    bindings:
      value: true


  class MyView extends BackBacon.View
    bindings:
      result: true

  myOtherView1 = new MyOtherView( $('#model1View'), model1 )
  myOtherView2 = new MyOtherView( $('#model2View'), model2 )
  myView = new MyView( $('#model3View'), model3 )
