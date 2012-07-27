Foresight.SchedulerView = Backbone.View.extend(
  events:
    'keyup': 'validate'
    'click .reset': 'reset'
    'click .schedule': 'schedule'
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
  render: ->
    @$el.html("""
      <div class="header">
        Schedule Message for <span class="date label label-important">No date selected</span>
      </div>
      <form>
        <label>Patient Id</label>
        <div class="input-append">
          <input type="text" class="patientId span2"><a class="indicator btn btn-danger"><i class="icon-remove-sign"></i></a>
        </div>
        <label>Message</label>
        <textarea class="span3"></textarea>
        <div>
          <a class="btn btn-success schedule" disabled="disabled">Schedule</a>
          <a class="btn reset">Reset</a>
        </div>
      </form>
    """)
    @btnEl = @$('.indicator')
    @iconEl = @$('.indicator i')
    @patientEl = @$('.patientId')
    @dateEl = @$('.date')
    @
  className: 'scheduler'
  onPatientChange: (value = '') ->
    value = value.trim()
    @setPatient(null)
    if value
      $.ajax(
        data:
          group: true
          key: """ "#{value}" """
        url: '/kujua/_design/kujua-foresight/_view/registrations'
        complete: (response) =>
          rows = JSON.parse(response.responseText)?.rows
          @setPatient(rows?[0])
          @validate()
      )
  validate: (e) ->
    if $(e?.target).is('.patientId')
      @onPatientChange(e.target.value)
    else
      valid = @validDate and @$('.indicator').hasClass('btn-success') and @$('textarea').val().trim() isnt ''
      if valid
        @$('.schedule').removeAttr('disabled')
      else
        @$('.schedule').attr('disabled', 'disabled')
  setPatient: (row) ->
    @patient = row?.value
    @btnEl.removeClass('btn-warning btn-success btn-danger')
    @iconEl.removeClass('icon-ok-sign icon-ban-sign icon-question-sign')
    if @patient
      @btnEl.addClass('btn-success')
      @iconEl.addClass('icon-ok-sign')
    else
      @btnEl.addClass('btn-danger')
      @iconEl.addClass('icon-ban-sign')
  reset: (e) ->
    @$('form')[0].reset()
    @onPatientChange()
    @validate()
    @patientEl[0].focus()
    @$
  schedule: ->
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
      data:
        _rev: _rev
      url: "/kujua/#{_id}"
    )
)
