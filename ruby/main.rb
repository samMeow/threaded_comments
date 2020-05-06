require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sequel'
require 'dotenv'



class Time
    def to_s
        self.iso8601
    end
end

class MyApp < Sinatra::Base
    Sequel.default_timezone = :utc
    Sequel::Model.plugin :json_serializer
    Sequel::Model.plugin :insert_returning_select


    template = 'postgres://%{username}:%{password}@%{host}:%{port}/%{database}%{query}'

    configure :development do
        register Sinatra::Reloader
        Dotenv.load
    end

    configure :production do
        Dotenv.load('.env')
    end

    configure :development, :production do
        Sequel.connect(template % {
            username: ENV['POSTGRES_USERNAME'],
            password: ENV['POSTGRES_PASSWORD'],
            host: ENV['POSTGRES_HOST'],
            port: ENV['POSTGRES_PORT'],
            database: ENV['POSTGRES_DATABASE'],
            query: '?sslmode=disable'
        }, max_connections: 4)
    end

    configure :test do
        Sequel.connect('mock://postgres')
    end
    
    Dir[File.join(__dir__, 'helpers', '*.rb')].each{|file| require file}
    Dir[File.join(__dir__, 'routes', '*.route.rb')].each{|file| require file}
    Dir[File.join(__dir__, 'models', '*.rb')].each{|file| require file}

    # ... app code here ...
    use CommentRoute
    use UserRoute
    use ThreadRoute
    # start the server if ruby file executed directly
    run! if app_file == $0
end