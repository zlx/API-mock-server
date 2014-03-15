ENV['RACK_ENV'] = 'test'

require File.join(File.dirname(__FILE__), '../boot')
require 'rspec'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end

