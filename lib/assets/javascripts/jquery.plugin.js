;(function($, window, document, undefined) {
  // Create a jQuery plugin from a object. Prevents against multiple
  // instantiations and allows any public function  (ie. a function whose name
  // doesn't start with an underscore) to be called.
  // https://github.com/jquery-boilerplate/jquery-boilerplate/wiki/Extending-jQuery-Boilerplate
  //
  // To create a plugin from a object named *MyPlugin*
  //   $.plugin('myPlugin', MyPlugin);
  //
  // To create a instance of the plugin (ie. attach it to element(s))
  //   $(element).myPlugin();
  //
  // To call a method on the plugin.
  //   $(element).myPlugin('functionName', arg1, arg2)
  //
  $.plugin = function(name, object) {
    $.fn[name] = function (options) {
        var args = arguments;
        var dataName = "plugin_" + name;

        // Is the first parameter an object (options) or was omitted,
        // instantiate a new instance of the plugin.
        if (options === undefined || typeof options === 'object') {
          return this.each(function() {
            // Only allow the plugin to be instantiated once,
            // so we check that the element has no plugin instantiation yet.
            if (!$.data(this, dataName)) {
              // If it has no instance, create a new one,
              // pass options to our plugin constructor,
              // and store the plugin instance
              // in the elements jQuery data object.
              $.data(this, dataName, new object(this, options));
            }
          });

        // If the first parameter is a string and it doesn't start
        // with an underscore or "contains" the `init`-function,
        // treat this as a call to a public method.
        } else if (typeof options === 'string' && options[0] !== '_' && options !== 'init') {
          // Cache the method call to make it possible to return a value
          var returns;

          this.each(function () {
            var instance = $.data(this, dataName);

            // Tests that there's already a plugin-instance
            // and checks that the requested public method exists
            if (instance instanceof object && typeof instance[options] === 'function') {
              // Call the method of our plugin instance and pass it the supplied arguments.
              returns = instance[options].apply(instance, Array.prototype.slice.call(args, 1));
            } else {
              $.error('Method ' + options + ' does not exist on jQuery.' + name);
            }
          });

          // If the earlier cached method gives a value back return the value,
          // otherwise return this to preserve chainability.
          return returns !== undefined ? returns : this;
        } else {
          $.error('Method ' + options + ' does not exist on jQuery.' + name);
        }
    };
  };
})(jQuery, window, document);
