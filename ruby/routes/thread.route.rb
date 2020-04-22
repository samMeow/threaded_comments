require_relative 'CRUDRoute'
class ThreadRoute < CRUDRoute
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
        id = Models::Thread.insert(title: data["title"])
        Models::Thread.where(id: id).first.to_json
    end

    put '/threads/:id' do |id|
        data = JSON.parse request.body.read
        Models::Thread.where(id: id).update(title: data["title"])
        Models::Thread.where(id: id).first.to_json
    end
end