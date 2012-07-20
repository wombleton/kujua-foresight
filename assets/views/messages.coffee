#= require ../collections/messages
#= require message

Foresight.MessagesView = Backbone.View.extend(
  initialize: ->
    @messages = new Foresight.Messages()
    @messages.bind('reset', _.bind(@render, @))
    Foresight.bus.bind('calendar:select-date', (el, year, month, date) =>
      _.extend(@messages,
        year: year
        month: month
        date: date
      )
      @messages.fetch()
    )
    @render()
  render: ->
    if @messages.year and @messages.length
      @$el.html("<h3>Messages for #{Foresight.formatDate(new Date(@messages.year, @messages.month - 1, @messages.date))}</h3>")
      _.each(@messages.models, (message) ->
        @$el.append(new Foresight.MessageView(model: message).render().el)
      , @)
    else
      @$el.html("""
        <h3>No messages.</h3>
      """)
    $('#detail').height(document.documentElement.clientHeight - 70)
)
