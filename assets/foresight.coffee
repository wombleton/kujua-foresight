#= require underscore
#= require jquery
#= require backbone

#= require ns

#= require views/main

$(document).ready(->
  new Foresight.MainView(
    el: '#app'
  )
)
