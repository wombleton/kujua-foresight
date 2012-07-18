_ = require('underscore')
Snockets = require('snockets')
crypto = require('crypto')

module.exports = (root, path, settings, doc, callback) ->
  config = _.defaults(settings['kanso-assets'] or {},
    assets: 'assets'
    minify: false
    prefix: 'js'
    output: 'static/js'
  )

  { assets, minify, output, prefix } = config

  attachments = doc._attachments
  names = _.filter(_.keys(attachments), (name) ->
    /\.html$/.test(name)
  )
  _.each(names, (name, index) ->
    snockets = new Snockets()
    attachment = attachments[name]
    html = new Buffer(attachment.data, 'base64').toString()
    re = /<!--\s*js\((['"])(.+?)\1\)\s*-->/g
    finished = false
    while not finished
      match = re.exec(html)
      if match
        [comment, quote, file] = match
        snockets.getConcatenation("#{assets}/#{file}", minify: minify, async: false, (err, js) ->
          if err
            throw err
          else
            filename = "#{file.replace(/\.(coffee|js)/, '')}-#{crypto.createHash('md5').update(js).digest('hex').substring(0, 12)}.js"
            attachments["#{output}/#{filename}"] =
              content_type: 'text/javascript'
              data: new Buffer(js).toString('base64')
            html = html.replace(/<!--\s*js\((['"])(.+?)\1\)\s*-->/, """<script src="#{prefix}/#{filename}"></script>""")
            attachments[name] = {
              content_type: 'text/html'
              data: new Buffer(html).toString('base64')
            }
            console.log("Added #{output}/#{filename} with a path of #{prefix}/#{filename}")
        )
      else
        callback(null, doc) if index is names.length - 1
        finished = true
  )
