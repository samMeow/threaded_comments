require 'json-schema'
require 'rack'

require_relative 'CRUDRoute'
class CommentRoute < CRUDRoute
    get '/comments' do
        # debug
        Models::Comment.order(:id).all.to_json
    end

    get '/comments/list' do
        param = Rack::Utils.parse_query(request.query_string)
        JSON::Validator.validate!({
            type: 'object',
            required: ['thread_id'],
            properties: {
                'thread_id' => {
                    type: 'string',
                    pattern: '^\d+$',
                },
                'limit' => {
                    type: 'string',
                    pattern: '^[1-9]\d+$',
                },
                'offset' => {
                    type: 'string',
                    pattern: '^\d+$',
                },
                'order' => {
                    type: 'string',
                    enum: ['asc', 'desc'],
                },
            },
            additionalProperties: false,
        }, param)
        
        
        thread_id = param['thread_id'].to_i
        limit = (param['limit'] || 20).to_i + 1
        offset = (param['offset'] || 0).to_i
        order = param['order'] || 'desc'
        data = Models::Comment
            .grouped_order_with_time(order)
            .where(thread_id: thread_id)
            .limit(limit)
            .offset(offset)
            .all
        {
            meta: {
                has_next_page: data.length() == limit
            },
            data: data.map{|x| x.to_public}
        }.to_json
    end

    get '/comments/listPopular' do
        param = Rack::Utils.parse_query(request.query_string)
        JSON::Validator.validate!({
            type: 'object',
            required: ['thread_id'],
            properties: {
                'thread_id' => {
                    type: 'string',
                    pattern: '^\d+$',
                },
                'limit' => {
                    type: 'string',
                    pattern: '^[1-9]\d+$',
                },
                'offset' => {
                    type: 'string',
                    pattern: '^\d+$',
                },
            },
            additionalProperties: false,
        }, param)

        thread_id = param['thread_id'].to_i
        limit = (param['limit'] || 20).to_i + 1
        offset = (param['offset'] || 0).to_i
        data = Models::Comment
            .order_with_popular
            .where(thread_id: thread_id)
            .limit(limit)
            .offset(offset)
            .all
        {
            meta: {
                has_next_page: data.length() == limit
            },
            data: data.map{|x| x.to_public}
        }.to_json
    end

    get '/comments/:id' do |id|
        comment = Models::Comment.first(id: id)
        if comment == nil
            halt 404, {code: 404, message: "Comment #{id} not found"}
        end
        comment.to_public.to_json
    end

    post '/comments' do
        data = JSON.parse request.body.read
        JSON::Validator.validate!({
            type: 'object',
            # TODO: user id should get from auth (header/session) instead
            required: ['user_id', 'thread_id', 'message'],
            properties: {
                'user_id' => {
                    type: 'integer',
                    minimum: 1,
                },
                'thread_id' => {
                    type: 'integer',
                    minimum: 1,
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
        }, data)
        
        comment = Models::Comment.new(
            user_id: data['user_id'],
            thread_id: data['thread_id'],
            parent_id: nil,
            message: data['message']
        )
        if data.key?("parent_id")
            parent = Models::Comment.first(id: data["parent_id"])
            if parent == nil or data['thread_id'] != parent.thread_id
                json_error 409, "Parent Comment #{data["parent_id"]} not exist"
            end
            comment[:parent_id] = parent.id
            comment[:parent_path] = parent.path
            comment[:depth] = parent.depth + 1
        end
        
        comment.save
        comment.to_public.to_json
    end
end