Foresight.Month = Backbone.Model.extend(
  getId: ->
    time = @get('time')
    "month-#{time.getFullYear()}-#{time.getMonth() + 1}"
  getTitle: ->
    time = @get('time')
    "#{Foresight.months[time.getMonth()]} #{time.getFullYear()}"
  getDate: ->
    @get('time').getDate()
  getMonth: ->
    @get('time').getMonth() + 1
  getYear: ->
    @get('time').getFullYear()
)
