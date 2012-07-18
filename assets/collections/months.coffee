#= require ../models/month

Foresight.Months = Backbone.Collection.extend(
  comparator: (month) ->
    month.get('time')
  model: Foresight.Month
)
