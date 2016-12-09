require 'uri'
require 'pg'

class Article
  attr_accessor :title, :url, :description, :errors

  def initialize(hash = {})
    @title = hash["title"]
    @url = hash["url"]
    @description = hash["description"]
    @errors = []
  end

  def invalid_url?(url)
    response =`curl -s -o out.html -w '%{http_code}' #{url}`
    if (/2\d\d/ =~ response) == 0 || (/3\d\d/ =~ response) == 0
      return false
    end
    return true
  end

  def valid?

    if @url.strip == "" || @title.strip == "" || @description.strip == ""
      @errors << "Please completely fill out form"
    end

    if invalid_url?(@url)
      @errors << "Invalid URL"
    end

    if @description.length < 20
      @errors << "Description must be at least 20 characters long"
    end

    @url_tests =  db_connection do |conn|
      conn.exec("SELECT articles.url FROM articles")
    end

    @url_tests.each do |url_test|
     if url_test["url"].include?(@url)
       @errors << "Article with same url already submitted"
     end
    end

    @errors.empty?
   end

  def self.all
    articles = []

    db_connection do |conn|
      @all_articles = conn.exec_params("SELECT * FROM articles")
      @all_articles.each do |article|
        articles << Article.new(article)
      end
    end
    
    return articles

  end



end
