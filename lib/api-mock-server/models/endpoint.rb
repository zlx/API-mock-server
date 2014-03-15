module ApiMockServer
  class Endpoint
    include Mongoid::Document

    field :verb, type: String
    field :pattern, type: String
    field :response, type: String
    field :status, type: Integer
    field :params, type: Hash
    field :active, type: Boolean, default: true
    field :category, type: String, default: "未分类"
    field :desc, type: String

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
      args = args.slice("verb", "pattern", "response", "status", "active", "category", "desc")
      return args, ps
    end

    def fixed_args args
      self.class.fixed_args args
    end

  end
end
