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
      { contact, _id, _rev, patient_name, patient_id, patient_identifiers, tasks, scheduled_tasks } = doc
      phone = contact?.phone

      tasks ?= []
      last_message = null
      tasks.forEach((task) ->
        if task.timestamp
          last_message ?= task
          if last_message.timestamp < task.timestamp
            last_message = task
      )

      scheduled_tasks ?= []
      next_message = null
      scheduled_tasks.forEach((task) ->
        next_message ?= task
        if task.due < next_message?.due
          next_message = task
      )

      if Array.isArray(patient_identifiers) and phone
        patient_identifiers.forEach((id) ->
          emit(id,
            _id: _id
            _rev: _rev
            phone: phone
            patient_name: patient_name
            last_message: last_message
            next_message: next_message
          )
        )
      else if patient_id
        emit(patient_id,
          _id: _id
          _rev: _rev
          phone: phone
          patient_name: patient_name
          last_message: last_message
          next_message: next_message
        )
    reduce: (keys, values) ->
      if values.length > 0
        values.reduce((memo, row) ->
          memo.phone ?= row.phone
          memo.patient_name ?= row.patient_name
          if memo.next_message?.due < row.next_message?.due
            memo.next_message = row.next_message
          if memo.last_message?.timestamp > row.last_message?.timestamp
            memo.last_message = row.last_message
          memo
        , values[0])
      else
        values
