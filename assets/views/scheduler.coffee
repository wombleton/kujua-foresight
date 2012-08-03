#= require patient
#= require ../bootstrap-transition
#= require ../bootstrap-datepicker
#= require ../bootstrap-carousel
#= require ../bootstrap-button

Foresight.SchedulerView = Backbone.View.extend(
  events:
    'click .close': 'close'
    'keyup': 'validate'
    'click button[type=submit]': 'schedule'
  initialize: ->
    Foresight.bus.bind('calendar:select-date', (@month) =>
      @date = @month.getSelectedDate()
      @validDate = @date > new Date()
      @dateEl.html(Foresight.formatDate(@date))
      if @validDate
        @dateEl.addClass('label-success').removeClass('label-important')
      else
        @dateEl.append(' *').addClass('label-important').removeClass('label-success')
      @validate()
    )
    Foresight.bus.bind('patientid:change', (id) =>
      if id
        @$el.slideDown()
      else
        @$el.slideUp()
    )
    @render()
  render: ->
    @$el.html("""
      <div class="container scheduler">
        <div class="row">
          <a class="btn close"><i class="icon-chevron-up"></i></a>
        </div>
        <div class="row">
          <form class="span6">
            <div id="myCarousel" class="carousel slide">
              <div class="carousel-inner">
                <div class="item active">
                  I'm a sample message.
                </div>
                <div class="item">
                  I'm another sample message.
                </div>
                <div class="item">
                  I'm a third sample message.
                </div>
                <div class="item">
                  <textarea placeholder="Write your custom message here"></textarea>
                </div>
              </div>
              <a class="left carousel-control" href="#myCarousel" data-slide="prev">
                <i class="icon-arrow-left"></i>
              </a>
              <a class="right carousel-control" href="#myCarousel" data-slide="next">
                <i class="icon-arrow-right"></i>
              </a>
            </div>
            <div class="input-append date pull-left" data-date="" data-date-format="yyyy-mm-dd">
              <input class="span2" size="16" type="text" value="" readonly><span class="add-on"><i class="icon-calendar"></i></span>
            </div>
            <div class="btn-group pull-left" data-toggle="buttons-radio">
              <button class="active btn">AM</button>
              <button class="btn">Midday</button>
              <button class="btn">PM</button>
            </div>
            <button class="btn btn-primary pull-left" type="submit" data-scheduling-text="Scheduling ...">Schedule</button>
          </form>
        </div>
      </div>
    """)
    @patient_view = new Foresight.PatientView(model: null)
    @$('form').after(@patient_view.render().el)


    @$('.date').datepicker()
    @$('.carousel').carousel(
      interval: false
    )
    @$('[data-toggle=buttons-radio] button').button()
    @$('form').submit(-> false)
    @
  validate: (e) ->
    if $(e?.target).is('.patientId')
      @onPatientChange(e.target.value)
    else
      valid = @validDate and @$('.indicator').hasClass('btn-success') and @$('textarea').val().trim() isnt ''
      if valid
        @$('.schedule').removeAttr('disabled')
      else
        @$('.schedule').attr('disabled', 'disabled')
  schedule: (e) ->
    { _id, _rev, phone } = @patient
    $.ajax(
      complete: (response) =>
        doc = JSON.parse(response.responseText)
        tasks = doc.scheduled_tasks ?= []

        tasks.push(
          state: 'scheduled'
          due: @date.getTime()
          messages: [
            to: phone
            message: @$('textarea').val()
          ]
          type: 'manual_reminder'
        )
        $.ajax(
          complete: =>
            Foresight.bus.trigger('calendar:select-date', @month)
          data: JSON.stringify(doc)
          type: 'PUT'
          url: "/kujua/#{_id}"
        )
        @reset()
      data:
        _rev: _rev
      url: "/kujua/#{_id}"
    )
  close: ->
    @$el.slideUp()
    Foresight.bus.trigger('patientid:clear')
)
