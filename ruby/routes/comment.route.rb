require 'cgi'
require_relative 'CRUDRoute'
class CommentRoute < CRUDRoute
    get '/comments' do
        # debug
        Models::Comment.order(:id).all.to_json
    end

    get '/comments/list' do
        param = CGI.parse(request.query_string)
        thread_id = param['thread_id'][0].to_i
        limit = (param['limit'][0].to_i || 20) + 1
        offset = param['offset'][0].to_i
        order = param['order'][0] || 'desc'
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
        param = CGI.parse(request.query_string)
        thread_id = param['thread_id'][0].to_i
        limit = (param['limit'][0].to_i || 20) + 1
        offset = param['offset'][0].to_i
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
        comment = Models::Comment.new(
            user_id: data['user_id'],
            thread_id: data['thread_id'],
            parent_id: nil,
            message: data['message']
        )
        if data.key?("parent_id")
            parent = Models::Comment.first(id: data["parent_id"])
            if parent == nil
                halt 409, {code: 409, message: "Parent Comment #{data["parent_id"]} not exist"}
            end
            comment[:parent_id] = parent.id
            comment[:parent_path] = parent.path
            comment[:depth] = parent.depth + 1
        end
        
        comment.save
        comment.to_public.to_json
    end
end