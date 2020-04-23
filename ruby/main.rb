require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'dotenv'

Dotenv.load
Sequel.default_timezone = :utc
DB = Sequel.connect('postgres://postgres:example@127.0.0.1:5433/comment-demo?sslmode=disable', max_connections: 4)
Sequel::Model.plugin :json_serializer
Sequel::Model.plugin :insert_returning_select

Dir[File.join(__dir__, 'helpers', '*.rb')].each{|file| require file}
Dir[File.join(__dir__, 'routes', '*.route.rb')].each{|file| require file}
Dir[File.join(__dir__, 'models', '*.rb')].each{|file| require file}

class Time
    def to_s
        self.iso8601
    end
end

class MyApp < Sinatra::Base
    configure :development do
        register Sinatra::Reloader
    end
    # ... app code here ...
    use CommentRoute
    use UserRoute
    use ThreadRoute
    # start the server if ruby file executed directly
    run! if app_file == $0
end