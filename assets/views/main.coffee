#= require calendar
#= require messages
#= require scheduler

Foresight.MainView = Backbone.View.extend(
  events:
    'keyup .navbar-form input': 'onPatientChange'
  initialize: ->
    Foresight.bus.bind('patientid:set', (patient_id) =>
      @$('.navbar-form input').val(patient_id).focus()
    )
    Foresight.bus.bind('calendar:select-date', ->
      Foresight.bus.trigger('patientid:set', '')
    )
    @render()
  render: ->
    @$el.html("""
      <div class="navbar navbar-fixed-top">
        <div class="navbar-inner">
          <div class="container">
            <a class="brand clearfix" href="#">Kujua Foresight</a>
            <form class="navbar-form pull-right">
              <div class="input-append">
                <input type="text" class="span2" placeholder="Patient ID"><span class="add-on"><i class="icon-search"></i></span>
              </div>
            </form>
          </div>
        </div>
      </div>
      <header class="hide"></header>
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
    @scheduler = new Foresight.SchedulerView(el: @$('header'))
    @
  onPatientChange: _.debounce((e) ->
    Foresight.bus.trigger('patientid:change', $(e.target).val())
  , 100)
)
