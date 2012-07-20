module.exports = [
  {
    from: ''
    to: 'index.html'
  }
  {
    from: '/css/*'
    to: 'static/css/*'
  }
  {
    from: '/js/*'
    to: 'static/js/*'
  }
  {
    from: '/:year/:month/counts.json'
    to: '_view/counts'
    query:
      group: 'true'
      startkey: [':year', ':month', '0', '0']
      endkey: [':year', ':month', '99', '99']
  }
  {
    from: '/:year/:month/:date/messages.json'
    to: '_view/messages'
    query:
      key: [':year', ':month', ':date']
  }
]
