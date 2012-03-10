require "rubygems"
require "rake"
require "logger"

task :bootstrap => :environment do
  puts "Bootstrapping application!"
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrate")
end

task :environment, :env do |t, args|
  require 'bundler'
  require 'active_record'
  require 'load_db'
end
