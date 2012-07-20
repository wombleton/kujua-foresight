Foresight.Message = Backbone.Model.extend(
  getTime: ->
    time = new Date(@get('timestamp'))
    Foresight.formatDate(time)
)
