class CRUDRoute < Sinatra::Base
    before do
        content_type 'application/json'
    end
end