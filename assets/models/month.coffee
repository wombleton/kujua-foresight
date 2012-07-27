Foresight.Month = Backbone.Model.extend(
  getId: ->
    time = @get('time')
    "month-#{time.getFullYear()}-#{time.getMonth() + 1}"
  getTitle: ->
    time = @get('time')
    "#{Foresight.months[time.getMonth()]} #{time.getFullYear()}"
  getDate: ->
    @get('selectedDate')
  getMonth: ->
    @get('time').getMonth() + 1
  getYear: ->
    @get('time').getFullYear()
  getSelectedDate: ->
    date = new Date(@get('time'))
    if @get('selectedDate')
      date.setDate(@get('selectedDate'))
    date
)
