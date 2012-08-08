#= require underscore
#= require jquery
#= require backbone

#= require ns

#= require views/main
Foresight.bus = _.extend({}, Backbone.Events)

Foresight.months = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split(' ')
Foresight.formatDate = (date) ->
  date = new Date(date)
  "#{date.getDate()} #{Foresight.months[date.getMonth()]} #{date.getFullYear()}"


Foresight.changes = (since = 0) ->
  $.ajax(
    complete: (response) ->
      changes = JSON.parse(response.responseText)
      { last_seq } = changes
      if since > 0
        Foresight.bus.trigger('calendar:refresh')
      Foresight.changes(last_seq)
    data:
      filter: 'kujua-foresight/tasks'
      feed: 'longpoll'
      since: since
    url: '/kujua/_changes'
  )

$(document).ready(->
  new Foresight.MainView(
    el: '#app'
  )
  Foresight.config =
    am: Number($.kansoconfig('foresight_am')) or 8
    midday: Number($.kansoconfig('foresight_midday')) or 12
    pm: Number($.kansoconfig('foresight_pm')) or 17
  Foresight.changes()
)
