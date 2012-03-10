require 'rubygems'
require 'sinatra'
require 'rack-flash'
require 'active_record'
require 'uuid'

dbconfig = YAML.load(File.read('config/database.yml'))
ActiveRecord::Base.establish_connection dbconfig["#{settings.environment}"]

class Idea < ActiveRecord::Base
  validates_presence_of :body
  validates_presence_of :user_name
end

class Vote < ActiveRecord::Base
  validates_presence_of :uuid
  validates_presence_of :idea_id
end

enable :sessions
use Rack::Flash

before do
  unless request.cookies["uuid"]
    response.set_cookie("uuid", :value => uuid_generator.generate)
  end
end

get '/' do
  @cookies = request.cookies
  @ideas = Idea.all
  erb :index
end

post '/idea/new' do
  idea = Idea.create(params['idea'])
  if idea.valid?
    flash[:notice] = "Idea saved!"
    idea.save!
  else
    flash[:error] = "Idea invalid. Please supply an idea and username!"
  end
  redirect '/'
end


def uuid_generator
  @uuid ||= UUID.new
end
