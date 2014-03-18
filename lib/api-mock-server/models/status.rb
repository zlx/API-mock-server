module ApiMockServer
  class Status
    include Mongoid::Document

    field :code, type: Integer
    field :desc, type: String
  end
end
