# frozen_string_literal: true

class Server < Sinatra::Base
  # Load storage and config early so we can access it in other modules
  register Sinatra::Configs::Storage
  configure do
    set :config, settings.storage.load_data("config")
  end

  before do
    @config = settings.config

    @section = (request.path_info.split("/")[1] || "meta").to_sym
    @section = :meta unless @config[:sections].include?(@section)

    @section_config = @config[:sections][@section]
  end

  helpers Sinatra::AssetHelpers
  helpers Sinatra::ContentHelpers
  helpers Sinatra::Cookies
  helpers Sinatra::LayoutHelpers
  helpers Sinatra::MderbRenderer
  helpers Sinatra::StorageHelpers
  register Sinatra::Configs::Assets
  register Sinatra::Configs::I18n
  register Sinatra::Namespace
  register Sinatra::SiteModules::Blog
  register Sinatra::SiteModules::Guides
  register Sinatra::SiteModules::Install
  register Sinatra::SiteModules::LocaleSelect
  use Rack::Protection::PathTraversal

  configure do
    set :markdown_renderer, ::MarkdownRenderer.new
  end

  not_found do
    document = settings.storage.load_document("meta", "404")
    mderb(document)
  end

  get "/*/*" do |section, document_path|
    document = settings.storage.load_document(section, document_path)
    halt 404 unless document
    mderb(document)
  end

  get "/" do
    document = settings.storage.load_document("meta", "index")
    mderb(document)
  end
end
