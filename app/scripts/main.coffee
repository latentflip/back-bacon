require.config
  shim:
    underscore:
      exports: '_'
    backbone:
      exports: 'Backbone'
    bacon:
      exports: 'Bacon'

  paths:
    underscore: '../components/underscore/underscore'
    backbone: '../components/backbone/backbone'
    bacon: '../components/bacon/lib/Bacon'
    jquery: 'vendor/jquery.min'
 
require ['app'], (app) ->
  
