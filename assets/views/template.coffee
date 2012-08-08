#= require ../handlebars

Foresight.TemplateView = Backbone.View.extend(
  initialize: (options) ->
    { template } = options
    @template = Handlebars.compile(template)
  render: ->
    name = @patient?.patient_name or 'this patient'
    @$el.html("""
      #{@template(PatientName: name)}
    """)
    @
  className: 'item'
)
