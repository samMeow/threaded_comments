# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sequel'
require 'dotenv'

require_relative 'helpers/time'

# main application
class MyApp < Sinatra::Application
  Sequel.default_timezone = :utc
  Sequel::Model.plugin :json_serializer
  Sequel::Model.plugin :insert_returning_select

  configure :development do
    Dotenv.load('.env.dev', '.env')
    register Sinatra::Reloader
  end

  configure :production do
    Dotenv.load('.env')
  end

  configure :test do
    Dotenv.load('.env.test', '.env')
  end

  configure :development, :production, :test do
    Sequel.connect(ENV['POSTGRES_URL'], max_connections: 4)
  end

  Dir[File.join(__dir__, 'helpers', '*.rb')].sort.each { |file| require file }
  Dir[File.join(__dir__, 'routes', '*.route.rb')].sort.each do |file|
    require file
  end
  Dir[File.join(__dir__, 'models', '*.rb')].sort.each { |file| require file }

  options '*' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    200
  end

  # ... app code here ...
  use CommentRoute
  use UserRoute
  use ThreadRoute
end
