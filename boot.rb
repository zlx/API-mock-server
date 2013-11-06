require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path(".")
require 'sinatra/reloader'
require 'api-mock-server'
require 'config'
