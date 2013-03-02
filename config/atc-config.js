// Generated by CoffeeScript 1.3.3
(function() {

  require.config({
    urlArgs: '',
    paths: {
      i18n: 'helpers/i18n-custom',
      text: 'lib/require-text/text',
      json: 'lib/requirejs-plugins/json',
      hbs: 'lib/require-handlebars-plugin/hbs',
      jquery: 'lib/jquery-1.8.3',
      underscore: 'node_modules/underscore/underscore',
      backbone: 'node_modules/backbone/backbone',
      marionette: 'lib/backbone.marionette',
      aloha: 'lib/Aloha-Editor/src/lib/aloha',
      bootstrap: 'lib/bootstrap/js/bootstrap',
      select2: 'lib/select2/select2',
      'font-awesome': 'lib/Font-Awesome/css/font-awesome',
      handlebars: 'lib/require-handlebars-plugin/Handlebars',
      i18nprecompile: 'lib/require-handlebars-plugin/hbs/i18nprecompile',
      json2: 'lib/require-handlebars-plugin/hbs/json2',
      'template/helpers/recursive': 'helpers/hbs-helper-recursive'
    },
    shim: {
      jquery: {
        exports: 'jQuery',
        init: function() {}
      },
      underscore: {
        exports: '_'
      },
      backbone: {
        deps: ['underscore', 'jquery'],
        exports: 'Backbone'
      },
      marionette: {
        deps: ['underscore', 'backbone'],
        exports: 'Backbone',
        init: function() {
          var ret;
          ret = this.Backbone.Marionette;
          delete this.Backbone.Marionette;
          delete this.Backbone;
          return ret;
        }
      },
      bootstrap: {
        deps: ['jquery', 'css!lib/bootstrap/css/bootstrap'],
        exports: 'jQuery'
      },
      select2: {
        deps: ['jquery', 'css!./select2'],
        exports: 'Select2',
        init: function() {
          var ret;
          ret = this.Select2;
          delete this.Select2;
          return ret;
        }
      },
      aloha: {
        deps: ['bootstrap', 'config/aloha-config'],
        exports: 'Aloha'
      }
    },
    map: {
      '*': {
        text: 'lib/require-text/text',
        css: 'lib/require-css/css',
        less: 'lib/require-less/less',
        json: 'lib/requirejs-plugins/src/json',
        Handlebars: 'handlebars'
      }
    },
    hbs: {
      disableI18n: true
    }
  });

}).call(this);
