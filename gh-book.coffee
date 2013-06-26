define [
  'underscore'
  'backbone'
  'bookish/media-types'
  'bookish/controller'
  'bookish/models'
  'epub/models'
  'bookish/auth'
  'gh-book/views'
], (_, Backbone, MEDIA_TYPES, Controller, AtcModels, EpubModels, Auth, Views) ->

  DEBUG = true

  # Generate UUIDv4 id's (from http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript)
  uuid = b = (a) ->
    (if a then (a ^ Math.random() * 16 >> a / 4).toString(16) else ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, b))



  writeFile = (path, text, commitText) ->
    Auth.getRepo().write Auth.get('branch'), "#{Auth.get('rootPath')}#{path}", text, commitText

  readFile =       (path) -> Auth.getRepo().read       Auth.get('branch'), "#{Auth.get('rootPath')}#{path}"
  readBinaryFile = (path) -> Auth.getRepo().readBinary Auth.get('branch'), "#{Auth.get('rootPath')}#{path}"
  readDir =        (path) -> Auth.getRepo().contents   Auth.get('branch'), path


  # Links in a navigation document are relative to where the nav document resides.
  # If it does not live in the same directory then they need to be resolved to
  # an absolute path so content Models can be looked up
  resolvePath = (context, relPath) ->
    return relPath if context.search('/') < 0
    path = context.replace(/\/[^\/]*$/, '') + '/' + relPath.split('#')[0]
    # path may still contain '..' so clean those up
    parts = path.split('/')

    i = 0
    while i < parts.length
      switch parts[i]
        when '.' then parts.splice(i, 1)
        when '..' then parts.splice(i-1, 2); i -= 1
        else i++

    parts.join '/'




  Backbone.sync = (method, model, options) ->

    path = model.id or model.url?() or model.url

    console.log method, path if DEBUG
    ret = null
    switch method
      when 'read' then ret = readFile(path)
      when 'update' then ret = writeFile(path, model.serialize(), 'Editor Save')
      when 'create'
        # Create an id if this model has not been saved yet
        id = _uuid()
        model.set 'id', id
        ret = writeFile(path, model.serialize())
      else throw "Model sync method not supported: #{method}"

    ret.done (value) => options?.success?(value)
    ret.fail (error) => options?.error?(ret, error)
    return ret



  EpubModels.EPUB_CONTAINER.on 'error', (model) ->
    url = "https://github.com/#{Auth.get('repoUser')}/#{Auth.get('repoName')}/tree/#{Auth.get('branch')}/#{Auth.get('rootPath')}#{model.url()}"
    alert "There was a problem getting #{url}\nPlease check your settings and try again."

  resetDesktop = ->
    # Clear out all the content and reset `EPUB_CONTAINER` so it is always fetched
    AtcModels.ALL_CONTENT.reset()
    EpubModels.EPUB_CONTAINER.reset()
    EpubModels.EPUB_CONTAINER._promise = null

    # Begin listening to route changes
    # and load the initial views based on the URL.
    if not Backbone.History.started
      Controller.start()
    Backbone.history.navigate('workspace')


    # Change how the workspace is loaded (from `META-INF/content.xml`)
    #
    # `EPUB_CONTAINER` will fill in the workspace just by requesting files
    EpubModels.EPUB_CONTAINER.loaded().then () ->

      # fetch all the book contents so the workspace is populated
      EpubModels.EPUB_CONTAINER.each (book) -> book.loaded()


  XhtmlModel = AtcModels.BaseContent.extend
    defaults:
      # Set the default title to null so the path shows up instead of "Untitled"
      title: null
    mediaType: 'application/xhtml+xml'

    parse: (html) ->

      # The result of a Github PUT is an object instead of the new state of the model.
      # Basically ignore it.
      return {} if 'string' != typeof html

      # Rename elements before jQuery parses and removes them
      # (because they are not valid children of a div)

      html = "<body>#{html}</body>" if not /<body/.test html
      html = "<html>#{html}</html>" if not /<html/.test html

      html = html.replace(/html>/g, "prefix-html>")
      html = html.replace(/<\/head>/g, "</prefix-head>")
      html = html.replace(/body>/g, "prefix-body>")

      html = html.replace(/<html/g, "<prefix-html")
      html = html.replace(/<head>/g, "<prefix-head>")
      html = html.replace(/<body/g, "<prefix-body")

      $html = jQuery(html)

      $head = $html.find('prefix-head')
      $body = $html.find('prefix-body')

      # Change the `src` attribute to be a `data-src` attribute if the URL is relative
      $html.find('img').each (i, img) ->
        $img = jQuery(img)
        src = $img.attr 'src'
        return if /^https?:/.test src
        return if /^data:/.test src

        $img.removeAttr 'src'
        $img.attr 'data-src', src


      $images = $html.find('img[data-src]')
      counter = $images.length

      $images.each (i, img) =>
        $img = jQuery(img)
        src = $img.attr 'data-src'

        # Images are relative to the HTML file
        # and need to be relative to the root of the EPUB.
        # Fortunately the id of the HTML file is relative to the root of the EPUB.
        src = resolvePath(@id, src)

        # Load the image file somehow (see below for my github.js changes)
        doneLoading = readBinaryFile(src)
        .done (bytes, statusMessage, xhr) =>
          # Grab the mediaType from the response header (or look in the EPUB3 OPF file)
          mediaType = AtcModels.ALL_CONTENT.get(src).mediaType # xhr.getResponseHeader('Content-Type').split(';')[0]

          # Use the browser's Base64 encode if available
          encode = btoa or @Base64?.encode

          encoded = encode(bytes)
          $img.attr('src', "data:#{mediaType};base64,#{encoded}")

          counter--
          @set 'body', $body[0].innerHTML if counter == 0

        .fail ->
          counter--
          $img.attr('src', 'path/to/failure.png')

      return {head: $head[0]?.innerHTML, body: $body[0]?.innerHTML}


    serialize: ->
      head = @get 'head'
      body = @get 'body'
      $head = jQuery("<div class='unwrap-me'>#{head}</div>")
      $body = jQuery("<div class='unwrap-me'>#{body}</div>")

      # Replace all the `img[data-src]` attributes with `img[src]`
      $body.find('img[data-src]').each (i, img) ->
        $img = jQuery(img)
        src = $img.attr('data-src')
        $img.removeAttr('data-src')
        $img.attr 'src', src

      return """
        <html>
          <head>
            #{$head[0].innerHTML}
          </head>
          <body>
            #{$body[0].innerHTML}
          </body>
        </html>
        """

  MEDIA_TYPES.add XhtmlModel

  AtcModels_Folder_accepts = AtcModels.Folder::accepts()
  AtcModels_Folder_accepts.push XhtmlModel::mediaType
  AtcModels.Folder::accepts = -> AtcModels_Folder_accepts

  AtcModels.BookTocNode::accepts  = -> [ XhtmlModel::mediaType, AtcModels.Folder::mediaType, AtcModels.BookTocNode::mediaType ]
  EpubModels.PackageFile::accepts = -> [ XhtmlModel::mediaType, AtcModels.Folder::mediaType, AtcModels.BookTocNode::mediaType ]

  # Clear everything and refetch when the
  STORED_KEYS = ['repoUser', 'repoName', 'branch', 'rootPath', 'id', 'password']
  Auth.on 'change', () =>
    if not _.isEmpty(_.pick Auth.changed, STORED_KEYS)
      # If the user changed login state then don't reset the desktop
      return if Auth.get('rateRemaining') and Auth.get('password') and not Auth.previousAttributes()['password']

      resetDesktop()
      # Update session storage
      for key, value of Auth.toJSON()
        @sessionStorage?.setItem key, value

  #Auth.on 'change:repoName', resetDesktop
  #Auth.on 'change:branch', resetDesktop
  #Auth.on 'change:rootPath', resetDesktop


  # Load up the workspace and show the signin modal dialog
  if not Backbone.History.started
    Controller.start()
  Backbone.history.navigate('workspace')


  # Load from sessionStorage
  props = {}
  _.each STORED_KEYS, (key) ->
    value = @sessionStorage?.getItem key
    props[key] = value if value
  Auth.set props

  $signin = jQuery('#sign-in-modal')
  $signin.modal('show')
  $signin.on 'hide', ->
    # Delay so we have a chance to save the login/password if the user clicked "Sign In"
    setTimeout resetDesktop, 100
