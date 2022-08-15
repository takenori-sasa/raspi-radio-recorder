# @see https://michiomochi.com/blog/railsuninitialized-constant-activestorageblobanalyzable
Rails.application.reloader.to_prepare do
  ActiveStorage::Blob
end
