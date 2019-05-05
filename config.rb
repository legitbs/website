page '**', layout: false


configure :development do
  activate :livereload
end


set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

ignore '/statdump*'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  # activate :minify_javascript

  # Enable cache buster
  # activate :asset_hash

  # Use relative URLs
  activate :relative_assets

  # Or use a different image path
  # set :http_prefix, "/Content/images/"
end

# activate :deploy do |deploy|
#   deploy.method = :git
#   deploy.build_before = true
#   deploy.remote = 'github'
# end

activate :s3_sync do |s3_sync|
  s3_sync.bucket = 'staging.legitbs.net'
  s3_sync.region = 'us-east-1'
  s3_sync.aws_access_key_id = ENV['S3_ACCESS_KEY_ID']
  s3_sync.aws_secret_access_key = ENV['S3_ACCESS_KEY_SECRET']
end
