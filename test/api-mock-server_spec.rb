require_relative './spec_helper'

describe ApiMockServer do
  let(:app) { ApiMockServer::App }
  let(:route) { ApiMockServer::Endpoint.create(verb: 'get', pattern: '/me', response: '{"me": "ok"}', status: 200) }
  let(:login) { authorize("admin", "admin") }

  it "should halt when username or password is not right" do
    authorize 'admin', 'wrong password'
    get "/admin"
    expect(last_response.status).to eq(401)
  end

  context "Need authorize operations" do
    before do
      login
    end

    it "should render welcome page when username or password is right" do
      get "/admin"
      expect(last_response).to be_ok
      expect(last_response.body).to match("Select an API endpoint on the left to get started")
    end

    it "should render form for create new route" do
      get "/admin/new"
      expect(last_response).to be_ok
      expect(last_response.body).to match(/form action="\/admin\/new", method="post"/)
    end

    it "should create new route" do
      post "/admin/new", {route: {verb: 'get', pattern: '/me', active: 1, response: '{"me": "ok"}'}}
      expect(last_response).to be_ok
      expect(last_response.body).to match(/<span class="text text-danger">GET<\/span>/)
      expect(last_response.body).to match(/<strong>\/me<\/strong>/)
    end

    it "should render error when missing pattern" do
      post "/admin/new", {route: {verb: 'get', active: 1, response: '{"me": "ok"}'}}
      expect(last_response).to be_ok
      expect(last_response.body).to match(/Pattern 必须为 \/ 开头的合法 url/)
    end

    it "should render edit form" do
      get "admin/#{route.id}/edit"
      expect(last_response).to be_ok
      expect(last_response.body).to match(/form action="\/admin\/#{route.id}\/edit", method="post"/)
    end

    it "should edit route" do
      post "admin/#{route.id}/edit", {route: {verb: 'post'}, active: 1}
      expect(last_response).to be_ok
      expect(last_response.body).to match(/<span class="text text-danger">POST<\/span>/)
      expect(last_response.body).to match(/<strong>\/me<\/strong>/)
    end

    it "should render error when edit route not valid" do
      post "admin/#{route.id}/edit", {route: {verb: 'wrong'}, active: 1}
      expect(last_response).to be_ok
      expect(last_response.body).to match(/Verb 目前只支持以下方法: get, post, put, delete, patch/)
    end

    it "should delete route" do
      delete "/admin/#{route.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to match(/\/admin/)
    end

    it "should render error when destroy fail" do
      ApiMockServer::Endpoint.any_instance.stub(destroy: false)
      delete "/admin/#{route.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to match(/\/admin\/#{route.id}/)
    end

    it "should render show page" do
      get "/admin/#{route.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to match(/<span class="text text-danger">GET<\/span>/)
      expect(last_response.body).to match(/<strong>\/me<\/strong>/)
    end

    it "should render batch show page" do
      get "/admin/batch_show", pattern: route.pattern
      expect(last_response).to be_ok
      expect(last_response.body).to match(/<span class="text text-danger">GET<\/span>/)
      expect(last_response.body).to match(/<strong>\/me<\/strong>/)
    end
  end

  it "should access the created route" do
    get route.pattern

    expect(last_response.status).to eq route.status
    expect(last_response.body).to eq route.response
  end

  it "should match route with regexp *" do
    route = ApiMockServer::Endpoint.create(verb: 'get', pattern: '/me/*', response: '{"me": "*"}', status: 200)

    get "/me/1"

    expect(last_response).to be_ok
    expect(last_response.body).to eq route.response
  end

  context "Configurate" do
    before do
      ApiMockServer.setup do |config| 
        config.top_namespace = "/api/v1"
        config.admin_user = "admin"
        config.admin_password = 'zlx'
      end
    end

    after do
      ApiMockServer.setup do |config| 
        config.top_namespace = nil
        config.admin_user = nil
        config.admin_password = nil
      end
    end

    it "should match top namespace when config" do
      route = ApiMockServer::Endpoint.create(verb: 'get', pattern: '/me/*', response: '{"me": "*"}', status: 200)

      get "/api/v1#{route.pattern}"

      expect(last_response).to be_ok
      expect(last_response.body).to eq route.response
    end

    it "should not match url missing top namespace when config" do
      route = ApiMockServer::Endpoint.create(verb: 'get', pattern: '/me/*', response: '{"me": "*"}', status: 200)

      get route.pattern

      expect(last_response).to be_ok
      expect(last_response.body).to eq({error: "the route not exist now"}.to_json)
    end

    it "should config admin_user and admin_password" do
      authorize "admin", "zlx"

      get "/admin"

      expect(last_response).to be_ok
    end
  end
end
