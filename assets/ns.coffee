# namespace
@Foresight = {}

Foresight.bus = _.extend({}, Backbone.Events)

Foresight.months = 'Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec'.split(' ')
Foresight.formatDate = (date) ->
  "#{date.getDate()} #{Foresight.months[date.getMonth()]} #{date.getFullYear()}"
