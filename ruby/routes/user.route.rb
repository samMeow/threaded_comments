# frozen_string_literal: true

require 'json-schema'
require_relative 'crud.route'
require_relative '../models/user'

# /users
class UserRoute < CRUDRoute
  def initialize(app = nil, user_model = Models::User)
    super(app)
    @user_model = user_model
  end

  USER_SCHEMA = {
    type: 'object',
    required: ['name'],
    properties: {
      'name' => {
        type: 'string',
        minLength: 1
      }
    },
    additionalProperties: false
  }.freeze
  get '/users' do
    # debug
    json @user_model.order(:id).all
  end

  get %r{/users/([\d]+)} do |id|
    user = @user_model.with_pk(id)
    json_error 404, "User #{id} not found" if user.nil?
    json user
  end

  post '/users' do
    data = JSON.parse request.body.read
    JSON::Validator.validate!(USER_SCHEMA, data)
    json @user_model.create(name: data['name'])
  end

  put '/users/:id' do |id|
    data = JSON.parse request.body.read
    JSON::Validator.validate!(USER_SCHEMA, data)
    user = @user_model.find(id: id)
    json_error 404, "User #{id} not found" if user.nil?
    user.update(name: data['name'])
    json user
  end
end
