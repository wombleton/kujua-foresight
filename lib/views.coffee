module.exports =
  counts:
    map: (doc) ->
      tasks = doc.tasks or []
      scheduled_tasks = doc.scheduled_tasks or []

      list = tasks.concat(scheduled_tasks)
      list.forEach((item) ->
        ts = item.timestamp or item.due
        messages = item.messages
        sent = !item.due
        if ts and messages?.length
          date = new Date(ts)
          emit(["#{date.getFullYear()}", "#{date.getMonth() + 1}", "#{date.getDate()}", "#{date.getHours()}"], [messages.length, sent])
      )
    reduce: (keys, values) ->
      allSent = true
      sum = 0
      values.forEach(([count, sent]) ->
        allSent = false if sent is false
        sum += count
      )
      [sum, allSent]
  messages:
    map: (doc) ->
      tasks = doc.tasks or []
      scheduled_tasks = doc.scheduled_tasks or []

      list = tasks.concat(scheduled_tasks)

      list.forEach((item) ->
        ts = item.timestamp or item.due
        sent = !item.due
        messages = item.messages
        if ts and messages?.length
          date = new Date(ts)
          messages.forEach((message) ->
            emit(["#{date.getFullYear()}", "#{date.getMonth() + 1}", "#{date.getDate()}"],
              sent: sent
              timestamp: ts
              message: message.message
              to: message.to
            )
          )
      )
  registrations:
    map: (doc) ->
      { contact, _id, _rev, patient_identifiers } = doc
      phone = contact?.phone

      if Array.isArray(patient_identifiers) and phone
        patient_identifiers.forEach((id) ->
          emit(id,
            _id: _id
            _rev: _rev
            phone: phone
          )
        )
    reduce: (keys, values) ->
      values[0]
