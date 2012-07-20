#= require ../models/message

Foresight.Messages = Backbone.Collection.extend(
  comparator: (message) ->
    message.get('timestamp')
  model: Foresight.Message
  url: ->
    "/kujua/_design/kujua-foresight/_rewrite/#{@year}/#{@month}/#{@date}/messages.json"
  parse: (data) ->
    { rows } = data
    _.pluck(rows, 'value')
)
