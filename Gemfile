source "https://rubygems.org"

gem "sinatra"
gem "activerecord"
gem "sinatra-activerecord"
gem "session"
gem "sinatra-flash"

group :production do
  gem "pg" # this gem is required to use postgres on Heroku
end

group :development do
  gem "shotgun"
  gem "tux"
  gem "sqlite3"
end