# frozen_string_literal: true

require 'rack/test'
require 'rspec'
require 'sequel'
require 'dotenv'

Dotenv.load('.env.integration', '.env')
ENV['RACK_ENV'] = 'integration'
DB = Sequel.connect(ENV['POSTGRES_URL'], max_connections: 4)

require_relative '../../main'

# rpsec mxins
module RSpecMixin
  include Rack::Test::Methods
  def app
    MyApp
  end
end

# For RSpec 2.x and 3.x
RSpec.configure do |c|
  c.include RSpecMixin
  c.around(:each) do |example|
    DB.transaction(rollback: :always, auto_savepoint: true) { example.run }
  end
end
