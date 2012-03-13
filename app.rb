require 'rubygems'
require 'sinatra'
require 'sinatra/flash'
require 'uuid'
require 'json'
require './load_db'

class Idea
  def self.all_for_uuid(user_uuid)
    ideas = all.collect do |i|
      idea = JSON.parse(i)
      idea['already_voted'] = Vote.already_voted?( idea['id'], user_uuid )
      idea
    end
    ideas
  end

  def self.all
    idea_uuids = REDIS.zrange("sorted_votes", 0, -1)
    idea_uuids.collect{ |id| REDIS.get(id) }
  end

  def self.create!(idea = {})
    if valid_params?(idea)
      idea_uuid = uuid_generator.generate

      idea['votes'] = 0
      idea['uuid'] = idea_uuid
      REDIS.set(key(idea_uuid), JSON.dump(idea))
      REDIS.zadd("sorted_votes", 1, key(idea_uuid) )
      # TODO automatically vote
    else
      false
    end
  end

  def self.key(uuid)
    "globn:ideas:#{uuid}"
  end

  private

  def self.valid_params?(idea = {})
    if idea['body'] && idea['body'].size > 0 && idea['user_name'] && idea['user_name'].size > 0
      true
    else
      false
    end
  end
end

class Vote

  def self.create!(user_uuid, params)
    if valid_params?(params) && !already_voted?(params['idea_uuid'], user_uuid)
      # TODO: Make this an atomic commit
      idea_key = Idea.key(params['idea_uuid'])
      idea = REDIS.get( idea_key )
      idea = JSON.parse(idea)
      idea['votes'] += 1
      REDIS.set( idea_key, JSON.dump(idea) )

      REDIS.sadd( key_for_idea(idea['uuid']), user_uuid )
    else
      false
    end
  end

  private

  def self.valid_params?(params = {})
    if params['idea_uuid'] && REDIS.get(Idea.key(params['idea_uuid']))
      true
    else
      false
    end
  end

  def self.already_voted?(idea_uuid, user_uuid)
    REDIS.sismember( key_for_idea(idea_uuid), user_uuid )
  end

  def self.key_for_idea(uuid)
    "globn:votes:#{uuid}"
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
  @ideas = Idea.all_for_uuid(request.cookies["uuid"])
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

post '/vote' do
  if Vote.create!(request.cookies["uuid"], params['vote'])
    flash[:notice] = "Vote saved!"
  else
    flash[:error] = "Vote invalid."
  end
  redirect '/'
end


def uuid_generator
  @uuid ||= UUID.new
end
