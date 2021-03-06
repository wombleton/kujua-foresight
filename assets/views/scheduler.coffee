#= require patient
#= require template
#= require ../bootstrap-transition
#= require ../bootstrap-datepicker
#= require ../bootstrap-carousel
#= require ../bootstrap-button

Foresight.SchedulerView = Backbone.View.extend(
  events:
    'click .close': 'close'
    'slid .carousel': 'validate'
    'keyup': 'validate'
    'click button[type=submit]': 'schedule'
  initialize: ->
    Foresight.bus.bind('patientid:change', (id) =>
      @trigger('message:set', null)
      if id
        @$el.slideDown()
      else
        @$el.slideUp()
    )
    Foresight.bus.bind('calendar:select-date', =>
      @$el.slideUp()
    )
    Foresight.bus.bind('message:select', (message) =>
      @trigger('message:set', message)
      @$el.slideDown()
    )
    @templates = []
    Foresight.bus.bind('patient:change', (@patient) =>
      @validate()
      _.each(@templates, (template) ->
        template.patient = patient
        template.render()
      )
    )
    @bind('message:set', _.bind(@setMessage, @))
    @render()
  render: ->
    now = new Date()
    html = """
      <div class="container scheduler">
        <div class="row">
          <a class="btn close"><i class="icon-chevron-up"></i></a>
        </div>
        <div class="row">
          <form class="span6">
            <div id="templates" class="carousel slide">
              <div class="carousel-inner">
                <div class="item">
                  <textarea placeholder="Write your custom message here"></textarea>
                </div>
              </div>
              <a class="left carousel-control" href="#templates" data-slide="prev">
                <i class="icon-arrow-left"></i>
              </a>
              <a class="right carousel-control" href="#templates" data-slide="next">
                <i class="icon-arrow-right"></i>
              </a>
            </div>
            <div class="input-append date pull-left" data-date="#{now.getFullYear()}-#{now.getMonth() + 1}-#{now.getDate()}" data-date-format="yyyy-mm-dd">
              <input class="span2" size="16" type="text" value="" readonly><span class="add-on"><i class="icon-calendar"></i></span>
            </div>
            <div class="btn-group pull-left" data-toggle="buttons-radio">
              <button class="active btn" data-time="#{$.kansoconfig('foresight_am') or 8}">AM</button>
              <button class="btn" data-time="#{$.kansoconfig('foresight_midday') or 12}">Midday</button>
              <button class="btn" data-time="#{$.kansoconfig('foresight_pm') or 17}">PM</button>
            </div>
            <button class="btn btn-primary pull-left" type="submit" data-scheduling-text="Scheduling ...">Schedule</button>
          </form>
        </div>
      </div>
    """
    @$el.html(html)
    @button = @$('[type=submit]')
    @addTemplates()
    @patient_view = new Foresight.PatientView(model: null)
    @$('form').after(@patient_view.render().el)

    @$('.date').datepicker()
    @$('[data-toggle=buttons-radio] button').button()
    @$('form').submit(-> false)
    @
  addTemplates: ->
    templates = $.kansoconfig('foresight_templates', true) or []
    _.each(templates, (template) ->
      t = new Foresight.TemplateView(template: template)
      @templates.push(t)
      @$('.carousel .item:last').before(t.render().el)
    , @)
    @$('.carousel .item:first').addClass('active')
    @$('.carousel').carousel(
      interval: false
    )
  getText: ->
    item = @$('.carousel .item.active')
    textareas = item.find('textarea')
    if textareas.length
      textareas.val()
    else
      item.html()
  validate: (e) ->
    return unless @button
    valid = @patient and @getText()
    if valid
      @button.removeAttr('disabled')
    else
      @button.attr('disabled', 'disabled')
  updateTasks: (doc, phone) ->
    tasks = doc.scheduled_tasks ?= []

    if @message
      task = _.find(tasks, (task) ->
        message = task.messages[0]
        message and task.due is @message.get('timestamp') and message.message is @message.get('message') and message.to is @message.get('to')
      , @)
      if task
        task.messages[0].message = @getText()
        task.due = @getDate()
    else
      tasks.push(
        state: 'scheduled'
        due: @getDate()
        messages: [
          to: phone
          message: @getText()
        ]
        type: 'manual_reminder'
      )
  schedule: (e) ->
    { _id, _rev, phone } = @patient
    $.ajax(
      complete: (response) =>
        doc = JSON.parse(response.responseText)
        @updateTasks(doc, phone)
        $.ajax(
          data: JSON.stringify(doc)
          type: 'PUT'
          url: "/kujua/#{_id}"
        )
        @close()
      data:
        _rev: _rev
      url: "/kujua/#{_id}"
    )
  close: ->
    @$el.slideUp()
    Foresight.bus.trigger('patientid:set', '')
  getDate: ->
    datepicker = @$('.date').data('datepicker')
    date = datepicker.date
    date.setMinutes(0, 0, 0)
    date.setHours(@$('button[data-time].active').attr('data-time'))
    date.getTime()
  setDate: (timestamp) ->
    datepicker = @$('.date').data('datepicker')
    datepicker.date = date =  new Date(timestamp)
    datepicker.setValue()

    hour = date.getHours()

    { am, midday, pm } = Foresight.config
    if hour <= am
      @$("button[data-time=#{am}]").button('toggle')
    else if am < hour < pm
      @$("button[data-time=#{midday}]").button('toggle')
    else
      @$("button[data-time=#{pm}]").button('toggle')
  setMessage: (@message) ->
    if @message
      patient_id = @message?.get('patient_id') or ''
      Foresight.bus.trigger('patientid:set', patient_id)
      @patient_view.onPatientChange(patient_id)
      @setDate(@message.get('timestamp'))
      @$('.carousel').carousel(@$('.carousel .item').length - 1)
      _.delay(=>
        @$('textarea').val(@message.get('message')).select()
      , 400)
      @$('[type=submit]').html('Update')
    else
      @$('.carousel').carousel(0)
      @$('textarea').val('')
      date = new Date()
      date.setDate(date.getDate() + 1)
      date.setHours(0, 0, 0, 0)
      @setDate(date)
      @$('[type=submit]').html('Schedule')
)
