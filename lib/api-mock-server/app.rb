module ApiMockServer
  class App < Sinatra::Base

    configure do
      # for sinatra partial
      register Sinatra::Partial
      set :partial_template_engine, :erb

      use Rack::MethodOverride

      # for sinatra reloader code when development
      register Sinatra::Reloader

      # for use mongodb as backend
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
        if ApiMockServer::Endpoint.where(:category.exists => false).exists?
          @categories << "未分类"
          # 未分类可能重复添加
          @categories.uniq!
        end
      end
    end

    get '/document' do
      protected!
      prepare_api_list
      @routes = {}
      @categories.each do |c|
        if c != '未分类'
          @routes[c] = ApiMockServer::Endpoint.where(category: c)
        else
          @routes[c] = ApiMockServer::Endpoint.where(:category.exists => false)
        end
      end
      erb :apis, layout: :document
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

    get "/admin/batch_show" do
      protected!
      prepare_api_list
      @routes = Endpoint.where(pattern: params["pattern"])
      @route = @routes.try(:first)
      erb :batch_show
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
