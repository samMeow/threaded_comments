module Models
    class User < Sequel::Model(:users)
        one_to_many :comments
    end
end