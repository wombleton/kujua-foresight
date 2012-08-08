#= require ../collections/messages
#= require message

Foresight.MessagesView = Backbone.View.extend(
  initialize: ->
    @messages = new Foresight.Messages()
    @messages.bind('reset', _.bind(@updateMessages, @))
    $(window).on('resize', _.bind(@fixHeight, @))
    Foresight.bus.bind('calendar:select-date', (month) =>
      _.extend(@messages,
        year: month.getYear()
        month: month.getMonth()
        date: month.getDate()
      )
      @messages.fetch()
    )
    Foresight.bus.bind('calendar:refresh', =>
      @messages.fetch()
    )
    @render()
  render: ->
    @$el.html("""
      <h3>No messages</h3>
      <div class="messages-body"></div>
    """)
    @header = @$('h3')
    @body = @$('.messages-body')
    @fixHeight()

    @updateMessages()
  fixHeight: _.debounce(->
      h = document.documentElement.clientHeight - 70
      $('#detail').height(h)
      $('#detail .messages-body').height(h - 60)
    , 50)
  updateMessages: ->
    @body.html('')
    if @messages.year and @messages.length
      @header.html("Messages for #{Foresight.formatDate(new Date(@messages.year, @messages.month - 1, @messages.date))}")
      _.each(@messages.models, (message) ->
        @body.append(new Foresight.MessageView(model: message).render().el)
      , @)
    else
      @header.html('<h3>No messages.</h3>')
)
