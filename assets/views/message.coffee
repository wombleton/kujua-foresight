Foresight.MessageView = Backbone.View.extend(
  render: ->
    sent = @model.get('sent')
    icon = if sent then 'ok-sign' else 'bolt'
    @$el.html("""
      <div class="header">
        <i class="icon-#{icon}"></i>
        <span class="label label-info">#{@model.get('to')}</span>
        <span class="label label-">#{@model.getTime()}</span>
      </div>
      <div class="body">
        #{@model.get('message')}
      </div>
    """)
    @
  className: 'message'
)
