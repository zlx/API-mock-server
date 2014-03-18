require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path(".")
$: << File.expand_path("./lib/api-mock-server")
require 'sinatra/reloader'
Dir[File.join(File.dirname(__FILE__), "/lib/api-mock-server/models", "*.rb")].each { |f| require f }
require 'api-mock-server'
Dir[File.join(File.dirname(__FILE__), "/lib/api-mock-server/initializers", "*.rb")].each { |f| require f }
