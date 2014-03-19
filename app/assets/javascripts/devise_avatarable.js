//= require jquery.plugin
//= require jquery.remotipart
//= require jquery.Jcrop
//= require glow
//= require_tree .

$(function() {
  // Initialize the avatar cropper if it exists on the page.
  $('.devise-avatarable-select-crop').deviseAvatarableCropper();

  // Initialize the avatar editor if it exists on the page.
  // FYI: The avatar editor also has a cropper but handles the initialization itself
  // so that the cropper in the editor is named differently to avoid clashes.
  $('.devise-avatarable-editor').deviseAvatarableEditor();
});
