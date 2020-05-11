# frozen_string_literal: true

require 'json-schema'

require_relative 'crud.route'
require_relative '../models/thread'

# /threads
class ThreadRoute < CRUDRoute
  def initialize(app = nil, thread_model = Models::Thread)
    super(app)
    @thread_model = thread_model
  end

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
    @thread_model.order(:id).all.to_json
  end

  get '/threads/:id' do |id|
    thread = @thread_model.with_pk(id)
    json_error 404, "Thread #{id} not found" if thread.nil?
    json thread
  end

  post '/threads' do
    data = JSON.parse request.body.read
    JSON::Validator.validate!(THREAD_SCHEMA, data)
    json @thread_model.create(title: data['title'])
  end

  put '/threads/:id' do |id|
    data = JSON.parse request.body.read
    JSON::Validator.validate!(THREAD_SCHEMA, data)
    thread = @thread_model.with_pk(id)
    json_error 404, "Thread #{id} not found" if thread.nil?
    thread.update(title: data['title'])
    json thread
  end
end
