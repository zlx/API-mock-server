require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path(".")
$: << File.expand_path("./lib/api-mock-server")
require 'sinatra/reloader'
require 'api-mock-server'
require 'initializers/apimockserver'
