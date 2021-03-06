# frozen_string_literal: true

require 'rack/test'
require 'rspec'

ENV['RACK_ENV'] = 'test'

require_relative '../main'

# For Sinatra RSpec
module RSpecMixin
  include Rack::Test::Methods
  def app
    MyApp
  end
end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }
