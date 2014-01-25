Non-stupid non-digest assets in Rails 4
=======================================

What is it?
-----------

In Rails 4, there is no way to by default compile both digest and non-digest assets. This is a pain in the arse for almost everyone developing a Rails 4 app. This gem solves the problem with the minimum possible effort.

How do I install it?
--------------------

Just put it in your Gemfile

```ruby
gem "non-stupid-digest-assets"
```

If you want to whitelist non-digest assets for only certain files, you can configure a whitelist like this:

```ruby
# config/initializers/non_digest_assets.rb
require 'non_stupid_digest_assets'

NonStupidDigestAssets.whitelist = [/tinymce\/.*/, "full/file/path.txt"]
```

Be sure to give either a regex that will match the right assets or a full
path to the asset in question.

But shouldn't I always use the Rails asset helpers anyway?
----------------------------------------------------------

Yes. But there are some obvious cases where you can't do this:

* Third party libraries in `vendor/assets` that need to include e.g. css / images
* In a static error page, e.g. a 404 page or a 500 page
* Referencing the assets from outside your rails application

What about other solutions?
--------------------------
[sprockets-redirect](https://github.com/sikachu/sprockets-redirect) uses a rack middleware to 302 redirect to the digest asset. This is terrible for performance because it requires 2 HTTP requests, and it also hits your ruby stack. An asset request should be handled by your webserver (e.g. nginx) because that's what it's good at.

[This rake task](https://github.com/rails/sprockets-rails/issues/49#issuecomment-20535134) will solve this problem, but requires an extra rake task. It won't work by default with things like capistrano / heroku. And it requires you to manage the code in your app.

Why do I need digest assets at all?
-----------------------------------

Digests are used for cache busting. Remember that if you use the non-digest assets and serve them with far-future expires headers, you will cause problems with cached assets if the contents ever need to change. You must bear this in mind when using non-digest assets.

Why is this not the default / a config option in Rails 4?
---------------------------------------------------------

Good question. I think it should be. [Complain here](https://github.com/rails/sprockets-rails/issues/49)
