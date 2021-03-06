# frozen_string_literal: true

require 'json-schema'
require 'sinatra/reloader'

require_relative '../helpers/error.helper'

# rest route base
class CRUDRoute < Sinatra::Application
  set :show_exceptions, :after_handler
  helpers ErrorHelper

  configure :development do
    register Sinatra::Reloader
  end

  before do
    content_type 'application/json'
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Content-Type'
  end

  error JSON::ParserError do
    json_error(400, 'Invalid json')
  end

  error JSON::Schema::ValidationError do
    json_error(400, env['sinatra.error'].message)
  end

  error Sequel::ForeignKeyConstraintViolation do
    json_error(409, env['sinatra.error'].message)
  end
end
