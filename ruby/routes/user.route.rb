require 'json-schema'
require_relative 'CRUDRoute'

class UserRoute < CRUDRoute
    USER_SCHEMA = {
        type: 'object',
        required: ['name'],
        properties: {
            'name' => {
                type: 'string',
                minLength: 1
            }
        },
        additionalProperties: false,
    }

    get '/users' do
        #debug
        json Models::User.order(:id).all
    end

    get /\/users\/([\d]+)/ do |id|
        user = Models::User.with_pk(id)
        if user == nil
            json_error 404, "User #{id} not found"
        end
        json user
    end

    post '/users' do
        data = JSON.parse request.body.read
        JSON::Validator.validate!(USER_SCHEMA, data)
        json Models::User.create(name: data['name'])
    end

    put '/users/:id' do |id|
        data = JSON.parse request.body.read
        JSON::Validator.validate!(USER_SCHEMA, data)
        user = Models::User.find(id: id)
        if user == nil
            json_error 404, "User #{id} not found"
        end
        user.update(name: data['name'])
        json user
    end
end