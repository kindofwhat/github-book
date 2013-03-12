// Generated by CoffeeScript 1.3.3
(function() {

  define(['underscore', 'backbone', 'atc/controller', 'atc/models', 'epub/models', 'atc/auth', 'gh-book/views', 'css!atc'], function(_, Backbone, Controller, AtcModels, EpubModels, Auth, Views) {
    var $signin, DEBUG, b, readDir, readFile, resetDesktop, uuid, writeFile;
    DEBUG = true;
    uuid = b = function(a) {
      if (a) {
        return (a ^ Math.random() * 16 >> a / 4).toString(16);
      } else {
        return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, b);
      }
    };
    writeFile = function(path, text, commitText) {
      return Auth.getRepo().write(Auth.get('branch'), "" + (Auth.get('rootPath')) + path, text, commitText);
    };
    readFile = function(path) {
      return Auth.getRepo().read(Auth.get('branch'), "" + (Auth.get('rootPath')) + path);
    };
    readDir = function(path) {
      return Auth.getRepo().contents(Auth.get('branch'), path);
    };
    Backbone.sync = function(method, model, options) {
      var callback, error, id, path, ret, success,
        _this = this;
      success = options != null ? options.success : void 0;
      error = options != null ? options.error : void 0;
      callback = function(err, value) {
        if (err) {
          return typeof error === "function" ? error(model, err, options) : void 0;
        }
        return typeof success === "function" ? success(model, value, options) : void 0;
      };
      path = model.id || (typeof model.url === "function" ? model.url() : void 0) || model.url;
      if (DEBUG) {
        console.log(method, path);
      }
      ret = null;
      switch (method) {
        case 'read':
          ret = readFile(path, callback);
          break;
        case 'update':
          ret = writeFile(path, model.serialize(), 'Editor Save', callback);
          break;
        case 'create':
          id = _uuid();
          model.set('id', id);
          ret = writeFile(path, model.serialize(), callback);
          break;
        default:
          throw "Model sync method not supported: " + method;
      }
      ret.done(function(value) {
        return typeof success === "function" ? success(model, value, options) : void 0;
      });
      ret.fail(function(error) {
        return typeof error === "function" ? error(model, error, options) : void 0;
      });
      return ret;
    };
    AtcModels.SearchResults = AtcModels.SearchResults.extend({
      initialize: function() {
        var model, _i, _len, _ref,
          _this = this;
        _ref = AtcModels.ALL_CONTENT.models;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          model = _ref[_i];
          if (model.get('mediaType') !== 'text/x-module') {
            this.add(model, {
              at: 0
            });
          } else {
            this.add(model);
          }
        }
        AtcModels.ALL_CONTENT.on('reset', function() {
          return _this.reset();
        });
        AtcModels.ALL_CONTENT.on('add', function(model) {
          return _this.add(model);
        });
        return AtcModels.ALL_CONTENT.on('remove', function(model) {
          return _this.remove(model);
        });
      }
    });
    resetDesktop = function() {
      AtcModels.ALL_CONTENT.reset();
      EpubModels.EPUB_CONTAINER.reset();
      EpubModels.EPUB_CONTAINER._promise = null;
      if (!Backbone.History.started) {
        Controller.start();
      }
      Backbone.history.navigate('workspace');
      return EpubModels.EPUB_CONTAINER.loaded().then(function() {
        return EpubModels.EPUB_CONTAINER.each(function(book) {
          return book.loaded();
        });
      });
    };
    Auth.on('change', function() {
      if (!_.isEmpty(_.pick(Auth.changed, 'repoUser', 'repoName', 'branch', 'rootPath', 'password'))) {
        return resetDesktop();
      }
    });
    if (!Backbone.History.started) {
      Controller.start();
    }
    Backbone.history.navigate('workspace');
    $signin = jQuery('#sign-in-modal');
    $signin.modal('show');
    return $signin.on('hide', function() {
      return setTimeout(resetDesktop, 100);
    });
  });

}).call(this);
