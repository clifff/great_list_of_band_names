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
  args.with_defaults(:env => 'development')
  require 'active_record'
  dbconfig = YAML.load(File.read('config/database.yml'))
  ActiveRecord::Base.establish_connection dbconfig[args[:env]]
end
