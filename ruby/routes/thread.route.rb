# frozen_string_literal: true

require 'json-schema'

require_relative 'crud.route'

# /threads
class ThreadRoute < CRUDRoute
  THREAD_SCHEMA = {
    type: 'object',
    required: ['title'],
    properties: {
      'title' => {
        type: 'string',
        minLength: 1
      }
    },
    additionalProperties: false
  }.freeze

  get '/threads' do
    # debug
    Models::Thread.order(:id).all.to_json
  end

  get '/threads/:id' do |id|
    thread = Models::Thread.with_pk(id)
    json_error 404, "Thread #{id} not found" if thread.nil?
    json thread
  end

  post '/threads' do
    data = JSON.parse request.body.read
    JSON::Validator.validate!(THREAD_SCHEMA, data)
    json Models::Thread.create(title: data['title'])
  end

  put '/threads/:id' do |id|
    data = JSON.parse request.body.read
    JSON::Validator.validate!(THREAD_SCHEMA, data)
    thread = Models::Thread.with_pk(id)
    json_error 404, "Thread #{id} not found" if thread.nil?
    thread.update(title: data['title'])
    json thread
  end
end
