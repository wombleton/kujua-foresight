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
              <button class="active btn">AM</button>
              <button class="btn">Midday</button>
              <button class="btn">PM</button>
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
    Foresight.bus.trigger('patientid:set', '')
  setDate: (timestamp) ->
    datepicker = @$('.date').data('datepicker')
    datepicker.date = new Date(timestamp)
    datepicker.setValue()
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
      @setDate(new Date())
      @$('[type=submit]').html('Schedule')
)
