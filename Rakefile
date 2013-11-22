require "./app"
require "sinatra/activerecord/rake"
namespace :db do
  desc 'Load the seed data from db/seeds.rb'
  task :seed do
    seed_file = File.join('db/seeds.rb')
    load(seed_file) if File.exist?(seed_file)
  end
end