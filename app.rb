require 'rubygems'
require 'bundler'

Bundler.require

get '/' do
  unless request.cookies["uuid"]
    response.set_cookie("uuid", :value => uuid_generator.generate)
  end
  erb :index
end

def uuid_generator
  @uuid ||= UUID.new
end

