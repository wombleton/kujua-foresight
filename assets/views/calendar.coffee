#= require ../collections/months
#= require month

Foresight.CalendarView = Backbone.View.extend(
  initialize: ->
    @months = new Foresight.Months()
    $(window).on('resize scroll', _.bind(@onScroll, @))
    @onScroll()
    Foresight.bus.bind('calendar:select-date', ($day) =>
      $('.selected', @$el).removeClass('selected')
      $day.addClass('selected')
    )
  addMonth: (time, offset = 0) ->
    time = new Date(time)
    time.setDate(1)
    time.setHours(0, 0, 0, 0)
    time.setMonth(time.getMonth() + offset)
    month = new Foresight.Month(
      time: time
    )
    @months.add(month)
    monthView = new Foresight.MonthView(model: month).render().el
    index = @months.indexOf(month)
    if index is 0
      before = $(document.body).height()
      @$el.prepend(monthView)
      after = $(document.body).height()
      document.body.scrollTop = document.body.scrollTop + after - before
    else
      $("##{@months.at(index - 1).getId()}").after(monthView)
    month
  checkFuture: ->
    last = @months.at(@months.length - 1)
    if last
      el = document.getElementById(last.getId())
      { top, bottom } = el.getBoundingClientRect()
      if bottom < (document.documentElement.clientHeight + bottom - top)
        @addMonth(last.get('time'), 1)
        @checkFuture()
      else
        @checkPast()
    else
      @addMonth(new Date())
      @checkFuture()
  checkPast: ->
    first = @months.at(0)
    if first
      el = document.getElementById(first.getId())
      { bottom, top } = el.getBoundingClientRect()
      if bottom > 60
        @addMonth(first.get('time'), -1)
  onScroll: _.throttle(->
    @checkFuture()
  , 200, true)
)
