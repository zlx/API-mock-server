# encoding: utf-8
require 'json'

module ApiMockServer

  class << self
    attr_accessor :top_namespace
    attr_accessor :admin_user, :admin_password


    def setup
      yield self
    end
  end

  class Endpoint
    include Mongoid::Document

    field :verb, type: String
    field :pattern, type: String
    field :response, type: String
    field :status, type: Integer
    field :params, type: Hash
    field :active, type: Boolean, default: true
    field :category, type: String, default: "未分类"

    VALID_HTTP_VERBS = %w{get post put delete patch}

    validates_presence_of :response, :status, message: "不能为空"
    validates_inclusion_of :verb, in: VALID_HTTP_VERBS , message: "目前只支持以下方法: #{VALID_HTTP_VERBS.join(", ")}"
    validates_format_of :pattern, with: /\A\/\S*\Z/, message: "必须为 / 开头的合法 url"
    #validates_uniqueness_of :pattern, scope: [:verb], message: "和 verbs 该组合已经存在"

    def self.init_endpoint args
      args, ps = fixed_args args
      args = args.merge(params: ps)
      new(args)
    end

    def update_endpoint args
      args, ps = fixed_args args
      args = args.merge(params: ps) unless ps.empty?
      update_attributes(args)
    end

    private
    def self.fixed_args args
      ps ||= {}
      (args["params_key"]||[]).each_with_index do |params_name, index|
        ps[params_name] = args["params_value"][index]
      end
      ps = ps.delete_if {|k, v| k.blank? }
      args["status"] = args["status"].blank? ? 200 : args["status"].to_i
      args["active"] = !args["active"].nil?
      args = args.slice("verb", "pattern", "response", "status", "active", "category")
      return args, ps
    end

    def fixed_args args
      self.class.fixed_args args
    end

  end

  class App < Sinatra::Base
    register Sinatra::Partial
    use Rack::MethodOverride

    configure :development, :test do
      set :partial_template_engine, :erb
      register Sinatra::Reloader

      Mongoid.load!("mongoid.yml")
    end

    helpers do
      def protected!
        return if authorized?
        headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
        halt 401, "Not authorized\n"
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(request.env)
        @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [::ApiMockServer.admin_user||'admin', ::ApiMockServer.admin_password||'admin']
      end

      def prepare_api_list
        @categories = ApiMockServer::Endpoint.distinct(:category)
        @categories << "未分类" if ApiMockServer::Endpoint.where(:category.exists => false).exists?
      end
    end

    get "/admin" do
      protected!
      prepare_api_list
      erb :index
    end

    get "/admin/new" do
      protected!
      prepare_api_list
      @route = Endpoint.new
      erb :new
    end

    post "/admin/new" do
      protected!
      prepare_api_list
      @route = Endpoint.init_endpoint(params["route"])
      if @route.save
        erb :show
      else
        @error = @route.errors.full_messages
        erb :new
      end
    end

    get "/admin/:id/edit" do
      protected!
      prepare_api_list
      @route = Endpoint.find(params[:id])
      erb :edit
    end

    post "/admin/:id/edit" do
      protected!
      prepare_api_list
      @route = Endpoint.find(params[:id])
      if @route.update_endpoint(params[:route])
        erb :show
      else
        @error = @route.errors.full_messages
        erb :edit
      end
    end

    delete "/admin/:id" do
      protected!
      prepare_api_list
      content_type :json
      @route = Endpoint.find(params[:id])
      if @route.destroy
        {error: '删除成功', url: '/admin'}.to_json
      else
        {error: @route.errors.full_messages.join(", "), url: "/admin/#{params[:id]}"}.to_json
      end
    end

    get "/admin/:id" do
      protected!
      prepare_api_list
      @route = Endpoint.find params[:id]
      erb :show
    end

    ::ApiMockServer::Endpoint::VALID_HTTP_VERBS.each do |verb|
      send verb, '*' do
        pattern = params["splat"].first
        if pattern.match(::ApiMockServer.top_namespace.to_s)
          pattern = pattern.sub(::ApiMockServer.top_namespace.to_s, "")
          @route = Endpoint.where(verb: verb, pattern: pattern, active: true).first
          unless @route
            urls = params["splat"].first.split("/")[1..-2]
            @route = Endpoint.where(verb: verb, pattern: /^\/#{urls[0]}\/\*/, active: true).first
          end
          if @route
            content_type :json
            status @route.status
            @route.response
          end
        else
          {error: "the route not exist now"}.to_json
        end
      end
    end

  end
end
