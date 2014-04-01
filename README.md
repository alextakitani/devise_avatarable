# DeviseAvatarable

DeviseAvatarable adds avatar images to [Devise](http://github.com/plataformatec/devise).
You can upload a local image file, crop it and use it as your avatar image
in your Devise model. It supports multiple avatars per model for example a
standard avatar image and a cover image for user profiles.

Image upload, processing and storage is done with
[CarrierWave](https://github.com/carrierwaveuploader/carrierwave)

DeviseAvatarable supports Rails 4 and Devise 3.


## Installation

You must have installed and configured Devise first. Follow the guides on
https://github.com/plataformatec/devise.

Add DeviseAvatarable to your Gemfile and run the bundle command to install it:

```ruby
gem 'devise_avatarable'
```

After the Gem is installed you need to run the install generator:

```console
rails generate devise_avatarable:install
```

This will add the DeviseAvatarable module to Devise, include the required javascript
and stylesheets in your application and add configuration options to the
Devise initializer in <tt>config/initializers/devise.rb</tt>. Look for
"Configuration for :avatarable".


## Add Avatar(s) to your Devise model

To add a avatar or more avatars to your Devise you need to create a migration for
the new column and you need to add configuration options to the Devise initializer.

For example to add a avatar named "avatar" first create a migration and migrate your database:

```console
rails g migration add_avatar_to_users avatar:string
rake db:migrate
```

Now open <tt>config/initializers/devise.rb</tt> und search for
"Configuration for :avatarable". If you just started fresh you'll find a line in
there that looks like this:

```ruby
# config.avatar :avatar
```

Uncomment it. Thats it. When you start your application you can go to
<tt>users/avatar/edit</tt> to upload a avatar image.

Read on if you want to know more about how to configure the avatar size,
versions and the storage location and how to add more than one avatar.


## Edit avatars

There is two ways how your users can upload avatars. The classic way is to just
go to <tt>users/avatar/edit</tt> (the path helper for that is <tt>edit_user_avatar_path</tt>)
and upload and crop the avatar.

Remember: If your avatar name is not *avatar* just replace *avatar* in the
path helper with whatever name you have.


### The avatar editor widget

The more fancy way is to use the <tt>avatar_field</tt> form helper in a existing form
for example the edit registrations form. To change this form you first need to create
the Devise views via:

```console
rails generate devise:views
```

We just need to change <tt>app/views/devise/registrations/edit.html.erb</tt>
so you might want to delete everything else from <tt>app/views/devise</tt>.

Now open <tt>app/views/devise/registrations/edit.html.erb</tt> and add the
<tt>avatar_field</tt> to the form like this:

```ruby
<%= form_for(resource, :as => resource_name, :url => registration_path(resource_name), :html => { :method => :put }) do |f| %>
  <%= devise_error_messages! %>

  ...

  <%= f.avatar_field :avatar %>

  ...

  <div><%= f.submit "Update" %></div>
<% end %>
```

This will render a fancy avatar editor that lets your users upload and crop the
avatar right there without leaving the page.

#### Custom Events

The widget will send a custom event when the avatar was uploaded and cropped
successfully. You can attach to this event to for example change the current
user avatar image on the page like this:

```javascript
$('#devise_avatarable_editor_user_avatar').on('update', function(e) {
  $('.current-user-avatar img').attr('src', e.imgUrl);
});
```

#### Flash messages

The avatar editor widget uses Javascript to upload and crop the image.
To display the flash messages you need to modifying the flash message container
in your layout a little. Just add the class <tt>alert-js</tt>.
Fo the default Devise flash message container in <tt>app/views/layouts/application.html.erb</tt>
it would look like this:

```html
<p class="alert alert-js"><%= alert %></p>
```

This works by adding the flash message to a special header in the server response
and by binding to the Javascript event <tt>glow:flash</tt> in the client and showing
the flash message on the website. If you want to do your own stuff with the flash
message you can unbind from that event and bind it again:

```javascript
$(document).unbind('glow:flash').bind('glow:flash', function(evt, flash) {
  alert(flash.type, flash.message)
});
```
We use the [Glow Gem](https://github.com/zweitag/glow) for that.


## Display avatars

To display a avatar in your views use

```ruby
<%= devise_avatar_for @user, :avatar, :small %>
```

The first parameter is your Devise model, the second the name of the avatar and
the third is the avatar version (aka size). It will return a image tag for
the specified avatar.

To check if a avatar exists use:

```ruby
devise_avatar_present? @user, :avatar
```

This returns *true* or *false* whenever or not the avatar exists.

**Remember**: This will just check if a file was uploaded but not if the file
actually exists on the storage.


## Configure your avatar(s)

In this Readme we create a avatar named "avatar" as the installation example.
Let's create another avatar named "cover" that serves as a profile image for
your users.

First let's create a migration and migrate your database

```console
rails g migration add_cover_to_users cover:string
rake db:migrate
```

Now open <tt>config/initializers/devise.rb</tt> und search for "Configuration for :avatarable".
You should already see <tt>config.avatar :avatar</tt> that we added previously.
Lets add another line for our new avatar:

```ruby
config.avatar :cover, [1024, 200]
```

That's it. This will create everything for a avatar named "cover" with a size of
1024x200 Pixels. Start or restart your Rails server and goto <tt>users/cover/edit</tt>
and upload a image. Or use the fancy avatar editor in your form:

```ruby
<%= f.avatar_field :cover %>
```

### More configuration options

The <tt>config.avatar</tt> method supports more configuration options.
Here is a full example:

```ruby
config.avatar :cover,
  limit_to: [800, 800],
  convert_to: :png,
  editor_size: 400,
  versions: {
    mini: [50, 50],
    feed: [150, 150, { process: :resize_to_fill }],
    profile: [500, 500, { process: :resize_to_fit }]
  }
```

Let's walk through what this does:
  * <tt>limit_to</tt> - Together with the different sizes of your avatar we also store the
    original uploaded file. If you want to safe disk space, you can scale it down.
    The setting above will reduce the size of the uploaded image to a maximum of
    800x800px. Make sure this is not smaller than your largest version though.
  * <tt>convert_to</tt> - This will convert all images to the PNG format.
  * <tt>editor_size</tt> - This sets the size of the image in the avatar editor to 800x800px
  * <tt>versions</tt> - This creates 3 different sizes of the avatar *mini*, *feed*, *profile*
    in the specified size. You can also pass in a hash to specify the resize option:
    * <tt>resize_to_fill</tt> - (default) will resize the image in a way that will fill
      the specified size entirely. This may crop the image.
    * <tt>resize_to_fit</tt> - will resize the image in a way so it fits withing the specified
      size. The resulting image may be shorter or narrower than the specified size.

You can omit any of these options which falls back to the default settings then:
  * <tt>limit_to</tt> - <tt>[1000, 1000]</tt> (for no limit use *false*)
  * <tt>convert_to</tt> - <tt>:jpg</tt> (for no conversion user *false*)
  * <tt>editor_size</tt> - 200
  * <tt>versions</tt> - { default: [200, 200] }


### Use your own uploader

DeviseAvatarable uses [CarrierWave](https://github.com/carrierwaveuploader/carrierwave)
to upload and process avatars. CarrierWave uses a uploader class to controll things like
storage paths, allowed file extensions, default urls and other. DeviseAvatarable
will create such a class on the fly when it is needed or you can create one in your host
application to modify behavior by overwriting methods. For example if the model
is called *User* and the avatar attribute *avatar* the name of your uploader class
must be *UserAvatarUploader*. Put this in <tt>app/models/user_avatar_uploader.rb</tt>.


### Configur avatar storgae

By default, all uploads are stored under <tt>public/uploads</tt> in your application directory.
You can also configure it to use other storage locations such as Amazon S3, Google Storage,
Rackspace an other.

For example if you want to use Amazon S3 add <tt>gem 'Fog'</tt> to your Gemfile,
run the bundle command and change the <tt>config.avatar_storage</tt> option
in the Devise initializer under <tt>initializers/devise.rb</tt> like this:

```ruby
config.avatar_storage = {
  fog_credentials: {
    provider: 'AWS',
    aws_access_key_id: 'YOUR-ACCESS-KEY',
    aws_secret_access_key: 'YOUR-SECRET-ACCESS-KEY',
    region: 'us-east-1' # Optional, defaults to 'us-east-1'. If you are in Europe use 'eu-west-1'.
  },
  fog_directory: 'NAME-OF-YOUR-BUCKET'
}
```

Put in your access key and secret and change the bucket name and you are ready to go.

You can optionally include your CDN host name in the configuration. This is highly
recommended, as without it every request requires a lookup of this information.

```ruby
config.asset_host = "http://mybucket.s3-external-3.amazonaws.com"
```

If you don't know this information, just leave it out, upload something and check
the generated URL. You can also also configure this
[dynamically](https://github.com/carrierwaveuploader/carrierwave#dynamic-asset-host).


#### Other storage provider examples:

```ruby
  # Rackspace
  config.avatar_storage = {
    fog_credentials: {
      provider: 'Rackspace',
      rackspace_username: 'YOUR-USERNAME',
      rackspace_api_key: 'YOUR-API-KEY'
    },
    fog_directory: 'NAME-OF-YOUR-CONTAINER'
  }

  # Google Storage
  config.avatar_storage = {
    fog_credentials: {
      provider: 'Google',
      google_storage_access_key_id: 'YOUR-ACCESS-KEY',
      google_storage_secret_access_key: 'YOUR-SECRET-ACCESS-KEY'
    },
    fog_directory: 'NAME-OF-YOUR-CONTAINER'
  }
```

Tip: We use [Fog](https://github.com/fog/fog) to store avatars. Please check the
Fog documentation for all available configuration options.


## Generating default images

For users that haven't uploaded a avatar image you can display a default image.

This image must be in your applications asset directory (default <tt>app/assets/images</tt>)
and the name is configured via the <tt>default_name</tt> method in the uploader and
defaults to <tt>user_avatar_small_default.jpg</tt> for model *user*, avatar *avatar* and
version *small*.

You can also use a Rake task that comes with DeviseAvatarable
to generate default images:

```console
rake devise_avatarable_create_defaults
```

This will create default images for all configured avatars. The default image
is very simple with just a solid background color. To generate default
images for a specific avatar and to change the background color use:

```console
rake devise_avatarable_create_defaults avatar=avatar color=pink
```

To generate a avatar from a specific image file use:

```console
rake devise_avatarable_create_defaults avatar=avatar file=path/to/file.jpg
```

Make sure the file you specify fits the dimensions you have specified
for the avatar. That means it must be large enough and the aspect ratio must fit.


## Translations

DeviseAvatarable uses the following [locales](https://github.com/schneikai/devise_avatarable/blob/master/config/locales).
Add or change translations by adding or overwriting these files in your app.


## TODOs
* Add test!
* this is not tested to work for multiple Devise models.
* right now users can change their avatars without requiring the current password.
  this is different from devise where in the default installation you are required
  give your current password to change stuff.
* when uploading a new file it would be cool there would be a cancel button in the crop dialog
  that would just cancel the new image upload/crop and keep the old image.
* Glow also seemed a little huge for what it does. Maybe we can update https://github.com/ungue/xhr_flash
* When the uploaded image is smaller than the *editor_size* the crop region will be off
* if there was a error when uploading a file through the widget and you try to select
  another file nothing happens when you click upload for the second time.
* uploading photos in landscape format is messing up the widget layout.
* make uploads work on Heroku https://github.com/carrierwaveuploader/carrierwave/wiki/How-to%3A-Make-Carrierwave-work-on-Heroku
* the avatar editor widget form helper partial uses Twitter Bootstrap for the layout. Maybe we should
  also add a default layout if people want to use this without Bootstrap
* add to README: how to remove avatars?

### TODO MAYBE
* maybe we shoul use avatarable for attribute name everywhere instead of avatar.
  when we use avatar it looks like this is the actual attribute name/column name
  for the avatar while it might be cover or face or image or whatever

### TODO FEATURES
* add drag&drop uploads (https://rubygems.org/gems/blueimp-file-upload-rails)
* allow to upload from url
* use gravatar


## Licence

MIT-LICENSE. Copyright 2014 Kai Schneider.
