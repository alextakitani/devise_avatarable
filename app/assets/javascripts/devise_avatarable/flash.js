// Display the flash messages from xhr responses.
// https://github.com/zweitag/glow

$(document).bind('glow:flash', function(evt, flash) {
  console.log("avatarable");
  var type = flash.type;
  if(type == 'error') type = 'danger';
  if(type == 'notice') type = 'info';

  alert = $($('.alert-js')[0]).clone();
  alert.hide();
  alert.text(flash.message);
  alert.addClass('alert-' + type);
  alert.insertAfter($('.alert-js')).fadeIn().delay(3000).fadeOut(function() { $(this).remove(); });
});
