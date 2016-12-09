require "sinatra"
require "pg"
require "uri"
require_relative "./app/models/article"
require 'pry'

set :views, File.join(File.dirname(__FILE__), "app", "views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/articles'
end

get '/articles' do

  db_connection do |conn|
    @tables = conn.exec("SELECT * FROM articles")
  end

  erb :index
end

get '/articles/new' do
  erb :new
end

post '/articles/new' do
  article_obj = Article.new({
    "title" => params[:title],
    "url" => params[:url],
    "description" => params[:description]
  })

  if article_obj.valid?
    db_connection do |conn|
      conn.exec_params("INSERT INTO articles(title, url, description) VALUES ($1, $2, $3)", [article_obj.title, article_obj.url, article_obj.description])
    end
    redirect '/articles'
  end
  @errors = article_obj.errors
  erb :new
end
