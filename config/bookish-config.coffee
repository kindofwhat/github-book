# Configure paths to all the JS libs
require.config

  urlArgs: '' # If you want to force a reload every time use this: `cb=#{Math.random()}` (you lose JS breakpoints though)

  # # Configure Library Locations
  paths:
    # ## Requirejs plugins
    i18n: 'helpers/i18n-custom'
    text: 'lib/require-text/text'
    json: 'lib/requirejs-plugins/json'
    hbs: 'lib/require-handlebars-plugin/hbs'

    # ## Core Libraries
    jquery: 'lib/jquery-1.8.3'
    underscore: 'node_modules/underscore/underscore'
    backbone: 'node_modules/backbone/backbone'
    # Layout manager for backbone
    marionette: 'lib/backbone.marionette'

    # ## UI libraries
    aloha: 'http://wysiwhat.github.io/Aloha-Editor/src/lib/aloha'
    # Link to the Tooltip just so something is requested and loaded.
    # Bootstrap attaches itself to jQuery anyway.
    bootstrap: 'lib/bootstrap-2.2.2/js/bootstrap-popover'
    'bootstrap-path': 'lib/bootstrap-2.2.2/js'

    select2: 'lib/select2/select2'

    'font-awesome': 'lib/Font-Awesome/css/font-awesome'

    # ## Handlebars Dependencies
    # The requirejs plugin to support handlebars has several dependencies
    # that need to be loaded
    handlebars: 'lib/require-handlebars-plugin/Handlebars'
    i18nprecompile: 'lib/require-handlebars-plugin/hbs/i18nprecompile'
    json2: 'lib/require-handlebars-plugin/hbs/json2'

    # A Handlebars helper for making recursive templates (rendering trees)
    'template/helpers/recursive': 'helpers/hbs-helper-recursive'


  # # Shims
  # To support libraries that were not written for AMD
  # configure a shim around them that mimics a `define` call.
  #
  # List the dependencies and what global object is available
  # when the library is done loading (for jQuery plugins this can be `jQuery`)
  shim:

    # ## Core Libraries
    jquery:
      exports: 'jQuery'
      init: ->
        # this.jQuery.noConflict(true)
        this.jQuery.browser.version = 10000;
        this.jQuery

    underscore:
      exports: '_'

    backbone:
      deps: ['underscore', 'jquery']
      exports: 'Backbone'

    marionette:
      deps: ['underscore', 'backbone']
      exports: 'Backbone'
      # Since `marionette` is the last library that depends on a
      # global `Backbone` object we can delete it from the globals.
      #
      # We can also delete `_` at this point and can delete `Backbone.Marionette`
      # so we never always include `marionette` and never assume Marionette is already loaded as a dependency.
      #
      #      init: -> ret = @Backbone.Marionette; delete @Backbone.Marionette; delete @Backbone; delete @_; ret
      init: -> ret = @Backbone.Marionette; delete @Backbone.Marionette; delete @Backbone; ret

    # ## UI Libraries

    # Load all the dev versions of bootstrap files (some of which we may not use)
    bootstrap:
      deps: [
        'less!bootstrap-path/../less/bootstrap'
        'bootstrap-path/bootstrap-affix'
        'bootstrap-path/bootstrap-alert'
        'bootstrap-path/bootstrap-button'
        'bootstrap-path/bootstrap-carousel'
        'bootstrap-path/bootstrap-collapse'
        'bootstrap-path/bootstrap-dropdown'
        'bootstrap-path/bootstrap-modal'
        'bootstrap-path/bootstrap-scrollspy'
        'bootstrap-path/bootstrap-tab'
        'bootstrap-path/bootstrap-tooltip' # `bootstrap-popover` depends on this one
        'bootstrap-path/bootstrap-transition'
        'bootstrap-path/bootstrap-typeahead'
      ]
      exports: 'jQuery'

    # Ensure jQuery is loaded before any of the bootstrap files are loaded
    'bootstrap-path/bootstrap-affix'      : ['jquery']
    'bootstrap-path/bootstrap-alert'      : ['jquery']
    'bootstrap-path/bootstrap-button'     : ['jquery']
    'bootstrap-path/bootstrap-carousel'   : ['jquery']
    'bootstrap-path/bootstrap-collapse'   : ['jquery']
    'bootstrap-path/bootstrap-dropdown'   : ['jquery']
    'bootstrap-path/bootstrap-modal'      : ['jquery', 'bootstrap-path/bootstrap-transition']
    'bootstrap-path/bootstrap-scrollspy'  : ['jquery']
    'bootstrap-path/bootstrap-tab'        : ['jquery']
    'bootstrap-path/bootstrap-tooltip'    : ['jquery']
    'bootstrap-path/bootstrap-transition' : ['jquery']
    'bootstrap-path/bootstrap-typeahead'  : ['jquery']


    select2:
      deps: ['jquery', 'css!./select2']
      exports: 'Select2'
      init: -> ret = @Select2; delete @Select2; ret

    # Some of the Aloha plugins depend on bootstrap being initialized on jQuery
    # (like the popover plugin).
    #
    # Also, configure Aloha for the application using the `aloha-config` module.
    aloha:
      deps: ['bootstrap', 'config/aloha-config']
      exports: 'Aloha'

  # Maps prefixes (like `less!path/to/less-file`) to use the LESS CSS plugin
  map:
    '*':
      text: 'lib/require-text/text'
      css: 'lib/require-css/css'
      less: 'lib/require-less/less'
      json: 'lib/requirejs-plugins/src/json'
      # Newer versions of the `hbs` plugin refer to uppercase handlebars...
      Handlebars: 'handlebars'

  # ## Module and requirejs Plugin Configuration
  # This configures `requirejs` plugins (like `'hbs!...'`) and our modules (like `'bookish/views'`).
  #
  # Modules can get to the configuration by including the `module` dependency
  # and then calling `module.config()`
  hbs:
    disableI18n: true

# requirejs special-cases jQuery and allows it to be a global (doesn't call the init code below to clean up the global vars)
# To stop it from doing that, we need to delete this property
#
# unlike the other jQuery plugins bootstrap depends on a global '$' instead of 'jQuery'
#
#`delete define.amd.jQuery`
