// This is the avatar inline editor tool. It lets you upload a image and select
// a crop from that image to create a new avatar.
//
// Important: We use Rails remote form functions here so if you wonder where all the ajax
// callbacks are defined this is handled by Rails via the *crop.js.erb* and *update.js.erb* templates.

window.DeviseAvatarable || (window.DeviseAvatarable = {});

(function($) {
  DeviseAvatarable.Editor = function(element, options) {
    var that = this;
    this.element = $(element);
    // Create the options. *options* will overwrite data attributes on the
    // element will overwrite defaults.
    this.options = $.extend({}, this.defaults, this.element.data(), options);

    this.form = this.element.parents('form');

    // Display server errors (500) to the user.
    // TODO: I couldn't figure out how to get the error message from the server
    // so I just display a general "Server is having hiccups. Please try again later.".
    // The error callback fires but the status is always 200 and the error is *parsererror*.
    // I'm pretty sure this has something to do with remotipart but wasn't sure how to fix that.
    // http://stackoverflow.com/questions/9334385/ajax-post-request-responds-with-an-html-element-when-including-an-attachment-wit
    $(document).off('ajax:error.deviseAvatarableEditor').on('ajax:error.deviseAvatarableEditor', this.form, function(e, xhr, status, error){
      // The error message is saved in the data attribute that we added when the
      // view was rendered so we can use translations.
      var alert = that.element.find(".devise-avatarable-errors"),
          message = alert.data('serverError');
      alert.html(message).show();
    });

    // Show the uploader.
    this.upload();
  };

  DeviseAvatarable.Editor.prototype = {
    defaults: {
      resource: 'user',
      attribute: 'avatar',
      url: '/users/avatars'
    },

    // The editor has two modes *upload* to upload a file and *crop* to select
    // a crop from the uploaded file.
    upload: function(image, removed) {
      var that = this;

      // Hide the cropper and show the uploader. If *image* is present we use it
      // as sourcefor the editor thumbnail.
      this.element.find('.devise-avatarable-cropper').hide();
      this.element.find('.devise-avatarable-uploader').show();
      if(image) this.element.find('.devise-avatarable-thumbnail').attr('src', image);

      // Show the remove avatar button if a avatar file is initally present
      // and the avatar was not just removed.
      var remove = this.element.find('.devise-avatarable-remove-btn');
      remove.hide();
      if(removed === false || (removed === undefined && remove.data('file-present'))) remove.show();

      // After a file was selected...
      this.element.find('.devise-avatarable-file').off('change.deviseAvatarableEditor').on('change.deviseAvatarableEditor', function() {
        that._uploadFile();
      });

      // When clicking the remove button...
      this.element.find('.devise-avatarable-remove-btn').off('click.deviseAvatarableEditor').on('click.deviseAvatarableEditor', function(e) {
        e.preventDefault();
        that._remove();
      });
    },

    crop: function(image) {
      var that = this;

      // Hide the uploader, show the cropper, load the newly uploaded image
      // to the cropper and initialize the crop tool (jCrop).
      var cropbox = this.element.find('.devise-avatarable-cropbox');
      this.element.find('.devise-avatarable-uploader').hide();
      this.element.find('.devise-avatarable-cropper').show();

      // Initialize the cropper for the very first request and call *update*
      // to make it start fresh for subsequent crops.
      cropbox.deviseAvatarableCropper({
        resource: this.options['resource'],
        attribute: this.options['attribute'],
        aspectRatio: this.options['aspectRatio']
      });

      cropbox.deviseAvatarableCropper('update', image);

      // When clicking the crop button...
      this.element.find('.devise-avatarable-crop-btn').off('click.deviseAvatarableEditor').on('click.deviseAvatarableEditor', function(e) {
        e.preventDefault();
        that._createCrop(cropbox.data('coords'));
      });
    },

    // Remove the current avatar.
    _remove: function(image) {
      this.element.find('.devise-avatarable-remove').val("1");
      this._submitForm();
      this._clearInputs();
    },

    // Upload the selected file to the Server.
    _uploadFile: function() {
      this._submitForm();
      this._clearInputs();
    },

    // Submit the selected crop coordinates to the server to create the crop.
    _createCrop: function(coords) {
      this.element.find('.devise-avatarable-crop').val(Array(coords.x, coords.y, coords.w, coords.h));

      this._submitForm();
      this._clearInputs();
    },

    // We modify the action of the form where the editor is added to submit to
    // the avatars controller. We also submit the form via ajax (set data-remote=true on the form).
    _submitForm: function() {
      var that = this,
          action = this.form.attr('action'),
          remote = this.form.data('remote');

      this.form.attr('action', this.options['url']);
      this.form.data('remote', true);

      this.form.submit();

      // Reset initial form settings.
      this.form.attr('action', action);
      if (remote !== undefined) {
        this.form.data('remote', remote);
      } else {
        this.form.removeData('remote');
      }

      // TODO: If there are more than one editor in the same form and after
      // one of them has submitted the form the *change* event of the other
      // editors file fields won't fire. I couldn't figure out why so for now
      // I just call the *upload* method on the other editors which will add
      // the events again.
      $('.devise-avatarable-editor').each(function() {
        if ($(this).attr('id') !== that.element.attr('id')) {
          $(this).deviseAvatarableEditor('upload');
        }
      });
    },

    // Clear all inputs for the avatar editor so we don't submit it
    // again when the user clicks *submit* to save his other changes to the form.
    _clearInputs: function() {
      this.element.find('.devise-avatarable-file').val("");
      this.element.find('.devise-avatarable-cache').val("");
      this.element.find('.devise-avatarable-crop').val("");
      this.element.find('.devise-avatarable-remove').val("");
    }
  };

  // Create a plugin.
  $.plugin('deviseAvatarableEditor', DeviseAvatarable.Editor);
})(jQuery);

