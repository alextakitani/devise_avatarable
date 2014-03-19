// The crop tool that wraps jCrop.
// By default the coordinates of the selection are saved in *data-coords*
// on the cropper element. This is configurable via the *saveCoordsTo* option.

window.DeviseAvatarable || (window.DeviseAvatarable = {});

(function($) {
  DeviseAvatarable.Cropper = function(element, options) {
    this.element = $(element);
    // Create the options. *options* will overwrite data attributes on the
    // element will overwrite defaults.
    this.options = $.extend({}, this.defaults, this.element.data(), options);

    // We save the html of the element and use this to remove jCrop later.
    // The jCrop *destroy* method didn't really work for me because when you
    // attach jCrop to a image it is added in some after-load hook and it might
    // be posible that the destroy method is not yet available when you want to
    // destroy it.
    this.elementHtml = this.element.html();

    this._attachCropper();
  };

  DeviseAvatarable.Cropper.prototype = {
    defaults: {
      resource: 'user',
      attribute: 'avatar',
      aspectRatio: 1,
      // Where to save the selection coordinates:
      // "data": Save as data attribute *coords* on the cropper element.
      // "[id]": A element id (ie a form element). For example *"#avatar_crop"*
      // [jquery element]: A jquery element (ie form element). For example *$('#avatar_crop')*.
      saveCoordsTo: 'data',
    },

    // Load a new image for the cropper.
    // If you already have a instance of the cropper running and just want to
    // set a new image (from a ajax callback for example) use this method.
    update: function(image) {
      this._destroyCropper();
      if(image) this.element.find('img').attr('src', image);
      this._attachCropper();
    },


    _attachCropper: function() {
      var that = this;
      this.element.find('img').Jcrop({
        aspectRatio: that.options['aspectRatio'],
        setSelect: [0, 0, 100, 100],
        onSelect: function(coords) { that._saveCoords(coords); },
        onChange: function(coords) { that._saveCoords(coords); }
      });
    },

    _saveCoords: function(coords) {
      var saveTo = this.options['saveCoordsTo'];

      if(saveTo === 'data') {
        this.element.data('coords', coords);
      } else {
        if(typeof saveTo !== 'object') saveTo = $(saveTo);
        saveTo.val(Array(coords.x, coords.y, coords.w, coords.h));
      }
    },

    _destroyCropper: function() {
      // This didn't work for me. If jCrop is attached it becomes available via the
      // data attribute only after the image it was attached to has completed loading.
      // So if you attach jCrop and need to destroy it right after this would fail.
      // if(this.image.data('Jcrop')) this.image.data('Jcrop').destroy();

      // Replace the elements html with the initial html. This will remove jCrop.
      // Update the image src attribute because this might have changed in the while.
      var image = this.element.find('img').attr('src');
      this.element.html(this.elementHtml);
      this.element.find('img').attr('src', image);
    }
  };

  // Create a plugin.
  $.plugin('deviseAvatarableCropper', DeviseAvatarable.Cropper);
})(jQuery);

