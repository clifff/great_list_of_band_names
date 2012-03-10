require "rubygems"
require "rake"
require "logger"

task :bootstrap => :environment do
    puts "Bootstrapping application!"
end

task :environment, :env do |t, args|
  require 'bundler'
  require 'load_db'
end
