# encoding: utf-8
require 'json'
require 'models/endpoint'
require 'app'

module ApiMockServer
  class << self
    attr_accessor :top_namespace
    attr_accessor :admin_user, :admin_password


    def setup
      yield self
    end
  end
end
