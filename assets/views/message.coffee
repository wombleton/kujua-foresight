Foresight.MessageView = Backbone.View.extend(
  events:
    'click .btn:not(.disabled)': 'editMessage'
  render: ->
    sent = @model.get('sent')
    if sent
      html = """
        <a class="btn disabled icon">
          <i class="icon-envelope"></i>
        </a>
      """
    else
      html = """
        <a class="btn icon">
          <i class="icon-bolt"></i>
        </a>
      """

    html += """
      <div class="body">
        <span class="label label-info">#{@model.get('patient_id')}</span>
        <span class="label label-">#{@model.getTime()}</span>
        #{@model.get('message')}
      </div>
    """
    @$el.html(html)
    @
  className: 'message'
  editMessage: ->
    Foresight.bus.trigger('message:select', @model)
)
