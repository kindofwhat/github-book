# Application Root
# =======
# This is the start of an abstract bookish application. Steps:
#
# 1. Load dependencies (JS/CSS/JSON)
# 2. Register client-side routes
#
# **TODO:** Load any HTML/JSON sent from the server that is sprinkled in the HTML file.
#
# For example, if the user goes to a piece of content we already send
# the content inside a `div` tag.
# The same can be done with metadata/roles (as a JSON object sent in the HTML)
define [
  'jquery'
  'underscore'
  'backbone'
  'marionette'
  'aloha'
  'bookish/auth'
  'bookish/controller'
], (jQuery, _, Backbone, Marionette, Aloha, Auth, Controller) ->

  # Application Code
  # =======

  # Begin listening to route changes
  # and load the initial views based on the URL.
  Controller.start()


  # Various HACKS
  # =======
  # These cross over many modules and do not have a better home than here.

  # ## Global Variables like jQuery
  # **HACK:** discourage people from using the global jQuery
  # and instead use the `requirejs` version.
  # This helps ensure plugins that extend jQuery (like bootstrap)
  # are properly listed as dependencies in requirejs' `define`
  @jQuery = @$ = ->
    console.warn 'You should add "jquery" to your dependencies in define() instead of using the global jQuery!'
    jQuery.apply @, arguments
  jQuery.extend(@jQuery, jQuery)

  # jQueryUI in Aloha relies on a very old function.
  # Used for re-ordering Authors and copyright holders
  # in the Select2 widget
  jQuery.curCSS = jQuery.css


  # Hash tags in links
  # =======
  # Code should use the `Controller` module to change the page
  # instead of relying on the URL
  #
  # For now, I trust that the programmer knows what they are doing and:
  #
  # 1. warn them
  # 2. trigger the route change
  # 3. hope a router matches that URL
  jQuery(document).on 'click', 'a:not([data-bypass])', (evt) ->
    evt.preventDefault()
    href = $(@).attr('href')
    console.warn "User clicked on an internal link. Use the bookish/controller module instead of the URL #{href}"

    # `Backbone.history.navigate` is sufficient for all Routers and will
    # trigger the correct events. The Router's internal `navigate` method
    # calls this anyways.
    #
    # Added the `javascript:` test because Select2 generates anchor links
    # but we should not change the URL.
    Backbone.history.navigate(href, true) if href? and not /^javascript:/.test(href)
