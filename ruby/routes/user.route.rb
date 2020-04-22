require_relative 'CRUDRoute'
class UserRoute < CRUDRoute
    get '/users' do
        #debug
        Models::User.order(:id).all.to_json
    end

    get '/users/:id' do |id|
        user = Models::User.where(id: id).first
        if user == nil
            halt 404, {code: 404, message: "User #{id} not found"}.to_json
        end
        user.to_json
    end

    post '/users' do
        data = JSON.parse request.body.read
        id = Models::User.insert(name: data['name'])
        Models::User.where(id: id).first.to_json
    end

    put '/users/:id' do |id|
        data = JSON.parse request.body.read
        Models::User.where(id: id)
            .update(name: data['name'])
        Models::User.where(id: id).first.to_json
    end
end