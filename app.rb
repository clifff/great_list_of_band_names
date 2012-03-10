require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'uuid'
require 'json'
require './load_db'

class Idea
  def self.all
    ideas = REDIS.lrange(key, 0, -1)
    ideas = ideas.collect{|i| JSON.parse(i)}
    ideas
  end

  def self.create!(idea = {})
    if valid_params?(idea)
      REDIS.lpush(key, JSON.dump(idea))
    else
      false
    end
  end

  private

  def self.key
    "globn:ideas"
  end

  def self.valid_params?(idea = {})
    if idea['body'] && idea['body'].size > 0 && idea['user_name'] && idea['user_name'].size > 0
      true
    else
      false
    end
  end
end

class Vote

  def already_voted?
  end
end

enable :sessions

set :public_folder, File.dirname(__FILE__) + '/public'

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
  if Idea.create!(params['idea'])
    flash[:notice] = "Idea saved!"
  else
    flash[:error] = "Idea invalid. Please supply an idea and username!"
  end
  redirect '/'
end


def uuid_generator
  @uuid ||= UUID.new
end
