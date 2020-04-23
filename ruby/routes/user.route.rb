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
        Models::User.order(:id).all.to_json
    end

    get /\/users\/([\d]+)/ do |id|
        user = Models::User.where(id: id).first
        if user == nil
            json_error 404, "User #{id} not found"
        end
        user.to_json
    end

    post '/users' do
        data = JSON.parse request.body.read
        JSON::Validator.validate!(USER_SCHEMA, data)
        id = Models::User.insert(name: data['name'])
        Models::User.where(id: id).first.to_json
    end

    put '/users/:id' do |id|
        data = JSON.parse request.body.read
        JSON::Validator.validate!(USER_SCHEMA, data)
        Models::User.where(id: id)
            .update(name: data['name'])
        Models::User.where(id: id).first.to_json
    end
end