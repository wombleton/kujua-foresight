Foresight.Month = Backbone.Model.extend(
  months: 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split(' ')
  getId: ->
    time = @get('time')
    "month-#{time.getFullYear()}-#{time.getMonth() + 1}"
  getTitle: ->
    time = @get('time')
    "#{@months[time.getMonth()]} #{time.getFullYear()}"
)
