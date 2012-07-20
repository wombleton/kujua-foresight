#= require calendar
#= require messages

Foresight.MainView = Backbone.View.extend(
  initialize: ->
    @render()
  render: ->
    @$el.html("""
      <div class="container">
        <div class="row">
          <div class="span12">
            <h1>Messages</h1>
          </div>
        </div>
        <div class="row">
          <div class="span8">
            <div id="calendar">&nbsp;</div>
          </div>
          <div class="span4" id="detail">
            <div id="messages"></div>
          </div>
        </div>
      </div>
    """)
    @calendar = new Foresight.CalendarView(el: '#calendar')
    @messages = new Foresight.MessagesView(el: '#messages')
    @
)

