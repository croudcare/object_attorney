require "bundler/gem_tasks"
require 'active_record'
require 'yaml'

ENV["RAILS_ENV"] ||= 'development'

task :default => :migrate
 
desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x"
task :migrate => :environment do
  ActiveRecord::Migrator.migrate('db/migrate', ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
end
 
task :environment do
  ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[ENV["RAILS_ENV"]])
  #ActiveRecord::Base.logger = Logger.new(File.open('tmp/database.log', 'a'))
end
