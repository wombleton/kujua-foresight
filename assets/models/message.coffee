Foresight.Message = Backbone.Model.extend(
  getTime: ->
    hour = new Date(@get('timestamp')).getHours()
    { am, midday, pm } = Foresight.config
    if hour <= am
      'AM'
    else if am < hour < pm
      'MIDDAY'
    else
      'PM'
)
