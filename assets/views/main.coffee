#= require calendar
#= require messages

Foresight.MainView = Backbone.View.extend(
  initialize: ->
    @render()
  render: ->
    @$el.html("""
      <div class="navbar navbar-fixed-top">
        <div class="navbar-inner">
          <div class="container">
            <a class="brand clearfix" href="#">Kujua Foresight</a>
          </div>
        </div>
      </div>
      <div class="container">
        <div class="row">
          <div class="span8">
            <div id="calendar">&nbsp;</div>
          </div>
          <div class="span4" id="detail">
          </div>
        </div>
      </div>
    """)
    @calendar = new Foresight.CalendarView(el: '#calendar')
    @messages = new Foresight.MessagesView(el: '#detail')
    @
)
