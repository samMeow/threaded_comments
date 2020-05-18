# frozen_string_literal: true

require 'json-schema'
require 'rack'

require_relative 'crud.route'
require_relative '../models/comment'

# rubocop:disable Metrics/ClassLength, Style/Documentation
class CommentRoute < CRUDRoute
  def initialize(app = nil, comment_model = Models::Comment)
    super(app)
    @comment_model = comment_model
  end

  # rubocop:enable Metrics/ClassLength, Style/Documentation
  get '/comments' do
    # debug
    json @comment_model.order(:id).all
  end

  GET_LIST_SCHEMA = {
    type: 'object',
    required: ['thread_id'],
    properties: {
      'thread_id' => {
        type: 'string',
        pattern: '^\d+$'
      },
      'limit' => {
        type: 'string',
        pattern: '^[1-9]\d*$'
      },
      'offset' => {
        type: 'string',
        pattern: '^\d+$'
      },
      'order' => {
        type: 'string',
        enum: %w[asc desc]
      }
    },
    additionalProperties: false
  }.freeze
  get '/comments/list' do
    param = Rack::Utils.parse_query(request.query_string)
    JSON::Validator.validate!(GET_LIST_SCHEMA, param)

    thread_id = param['thread_id'].to_i
    limit = (param['limit'] || 20).to_i
    offset = (param['offset'] || 0).to_i
    order = param['order'] || 'desc'
    data = @comment_model
           .grouped_order_with_time(order)
           .where(thread_id: thread_id)
           .limit(limit + 1)
           .offset(offset)
           .eager(:user)
           .all
    {
      meta: {
        has_next_page: data.length == limit + 1
      },
      data: data[0, limit].map(&:to_public)
    }.to_json
  end

  GET_POPULAR_SCHEMA = {
    type: 'object',
    required: ['thread_id'],
    properties: {
      'thread_id' => {
        type: 'string',
        pattern: '^\d+$'
      },
      'limit' => {
        type: 'string',
        pattern: '^[1-9]\d*$'
      },
      'offset' => {
        type: 'string',
        pattern: '^\d+$'
      }
    },
    additionalProperties: false
  }.freeze
  get '/comments/listPopular' do
    param = Rack::Utils.parse_query(request.query_string)
    JSON::Validator.validate!(GET_POPULAR_SCHEMA, param)

    thread_id = param['thread_id'].to_i
    limit = (param['limit'] || 20).to_i
    offset = (param['offset'] || 0).to_i
    data = @comment_model
           .eager(:user)
           .order_with_popular
           .where(thread_id: thread_id)
           .limit(limit + 1)
           .offset(offset)
           .all
    {
      meta: {
        has_next_page: data.length == limit + 1
      },
      data: data[0, limit].map(&:to_public)
    }.to_json
  end

  get '/comments/:id' do |id|
    comment = @comment_model.first(id: id)
    json_error "Comment #{id} not found" if comment.nil?
    json comment.to_public
  end

  POST_COMMENT_SCHEMA = {
    type: 'object',
    # TODO: user id should get from auth (header/session) instead
    required: %w[user_id thread_id message],
    properties: {
      'user_id' => {
        type: 'integer',
        minimum: 1
      },
      'thread_id' => {
        type: 'integer',
        minimum: 1
      },
      'message' => {
        type: 'string',
        minLength: 1
      },
      'parent_id' => {
        type: 'integer',
        minimum: 1
      }
    }
  }.freeze
  post '/comments' do
    data = JSON.parse request.body.read
    JSON::Validator.validate!(POST_COMMENT_SCHEMA, data)

    comment = @comment_model.new(
      user_id: data['user_id'],
      thread_id: data['thread_id'],
      parent_id: nil,
      message: data['message']
    )
    if data.key?('parent_id')
      parent = @comment_model.first(id: data['parent_id'])
      if parent.nil? || (data['thread_id'] != parent.thread_id)
        json_error 409, "Parent Comment #{data['parent_id']} not exist"
      end
      comment[:parent_id] = parent.id
      comment[:parent_path] = parent.path
      comment[:depth] = parent.depth + 1
    end

    comment.save
    json comment.to_public
  end

  post '/comments/:id/upvote' do |id|
    comment = @comment_model.with_pk(id)
    json_error 404, "Comment #{id} not found" if comment.nil?
    comment.update(upvote: comment.upvote + 1)
    # Add upvote history in database for more comprehensive forumn
    json comment.to_public
  end

  post '/comments/:id/downvote' do |id|
    comment = @comment_model.with_pk(id)
    json_error 404, "Comment #{id} not found" if comment.nil?
    comment.update(downvote: comment.downvote + 1)
    # Add upvote history in database for more comprehensive forumn
    json comment.to_public
  end
end
