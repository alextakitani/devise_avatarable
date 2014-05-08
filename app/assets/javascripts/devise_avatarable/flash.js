// Bind to the update event form the avatar editor to display a flash
// message when the vatar was updated.

$(document).bind('update', '.devise-avatarable-editor', function(event) {
  alert = $($('.alert-js')[0]).clone();
  alert.text(event.message);
  alert.addClass('alert-info');
  alert.insertAfter($($('.alert-js')[0])).fadeIn().delay(3000).fadeOut(function() { $(this).remove(); });
});
