Foresight.MonthView = Backbone.View.extend(
  events:
    'click .day': 'selectDay'
  initialize: ->
    @model.on('month:refresh', _.bind(@fetchData, @))
    @model.on('change:selectedDate', =>
      Foresight.bus.trigger('calendar:select-date', @model)
      @$("[data-date=#{@model.get('selectedDate')}]").addClass('selected')
    )
    @fetchData()
  render: ->
    weeksHtml = ""
    time = @model.get('time')
    marker = new Date(time.getTime())
    marker.setDate(1)
    month = marker.getMonth()
    marker.setDate(1 - marker.getDay())
    firstRun = true
    while firstRun or marker.getMonth() is month
      weeksHtml += @addWeek(marker, month)
      firstRun = false
    @$el.html("""
      <h2 class="title"> #{@model.getTitle()} </h2>
      <div class="row header">
        <div class="span1 day">Sun</div>
        <div class="span1 day">Mon</div>
        <div class="span1 day">Tue</div>
        <div class="span1 day">Wed</div>
        <div class="span1 day">Thu</div>
        <div class="span1 day">Fri</div>
        <div class="span1 day">Sat</div>
      </div>
      #{weeksHtml}
    """)
    @$el.attr('id', @model.getId())
    if @model.get('selectedDate')
      @$("[data-date=#{@model.get('selectedDate')}]").addClass('selected')
    @
  data: {}
  getCount: (date) ->
    @data[date]?[0] or 0
  getIcon: (date) ->
    sent = @data[date]?[1]
    if sent
      """<i class="icon-ok-sign"></i>"""
    else if sent is false
      """<i class="icon-bolt"></i>"""
    else
      ''
  fetchData: ->
    $.ajax(
      complete: (response) =>
        rows = JSON.parse(response.responseText)?.rows
        @data = _.reduce(rows, (counts, row) ->
          { key, value } = row
          [ year, month, date ] = key
          counts[Number(date)] = value
          counts
        , {})
        @render()
      url: "/kujua/_design/kujua-foresight/_rewrite/#{@model.getYear()}/#{@model.getMonth()}/counts.json"
    )
  addWeek: (marker, month) ->
    html = [ """<div class="row week">""" ]
    for i in [1..7]
      date = marker.getDate()

      if marker.getMonth() is month
        count = @getCount(date)
        icon = @getIcon(date)
        if icon
          cls = 'in messages'
        else
          cls = 'in'
      else
        cls = 'out'
        count = 0
        icon = ''

      html.push("""
        <div class="span1 day #{cls}" data-date="#{date}">
          <div class="date">
            #{date}
          </div>
          <div>
          </div>
          <div class="count">#{count or '&nbsp;'} #{icon}</div>
        </div>
      """)
      marker.setDate(marker.getDate() + 1)
    html.push("</div>")
    html.join('')
  className: 'month'
  selectDay: (e) ->
    $day = $(e.target).parents('.day')
    date = Number($day.attr('data-date'))
    if $day.is('.in')
      @model.set('selectedDate', date)
    else
      false
)
