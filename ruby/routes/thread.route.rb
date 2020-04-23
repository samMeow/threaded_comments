require 'json-schema'

require_relative 'CRUDRoute'
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
        additionalProperties: false,
    }

    get '/threads' do
        # debug
        Models::Thread.order(:id).all.to_json
    end

    get '/threads/:id' do |id|
        thread = Models::Thread.where(id: id).first
        if thread == nil
            halt 404, {code: 404, message: "Thread #{id} not found"}
        end
        thread.to_json
    end

    post '/threads' do
        data = JSON.parse request.body.read
        JSON::Validator.validate!(THREAD_SCHEMA, data)
        id = Models::Thread.insert(title: data["title"])
        Models::Thread.where(id: id).first.to_json
    end

    put '/threads/:id' do |id|
        data = JSON.parse request.body.read
        JSON::Validator.validate!(THREAD_SCHEMA, data)
        Models::Thread.where(id: id).update(title: data["title"])
        Models::Thread.where(id: id).first.to_json
    end
end