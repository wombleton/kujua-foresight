module.exports =
  tasks: (doc) ->
    { tasks, scheduled_tasks } = doc
    tasks ?= []
    scheduled_tasks ?= []
    Array.isArray(tasks) and !!tasks.concat(scheduled_tasks).length
