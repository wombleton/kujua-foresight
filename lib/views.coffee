module.exports =
  counts:
    map: (doc) ->
      tasks = doc.tasks or []
      scheduled_tasks = doc.scheduled_tasks or []

      list = tasks.concat(scheduled_tasks)
      list.forEach((item) ->
        ts = item.timestamp or item.due
        sent = !item.due
        if ts
          date = new Date(ts)
          emit(["#{date.getFullYear()}", "#{date.getMonth() + 1}", "#{date.getDate()}", "#{date.getHours()}"], [1, sent])
      )
    reduce: (keys, values) ->
      allSent = true
      sum = 0
      values.forEach(([count, sent]) ->
        allSent = false if sent is false
        sum += count
      )
      [sum, allSent]
