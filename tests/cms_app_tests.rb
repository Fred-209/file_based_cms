ENV["RACK_ENV"] = "test"


require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CmsAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    response_body = last_response.body

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes response_body, 'history.txt'
    assert_includes response_body, 'changes.txt'
    assert_includes response_body, 'about.txt'
  end

  def test_page_content
    get "/history.txt"
    body = last_response.body

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes body, "2003 - Ruby 1.8 released."
  end

  def test_non_existing_document
    get "/non_existing_doc.txt"

    assert_equal 302, last_response.status
    
    get last_response["Location"]

    assert_equal 200, last_response.status
    assert_includes last_response.body, "non_existing_doc.txt does not exist."
  
    get "/"

    refute_includes last_response.body, "non_existing_doc.txt does not exist."
  end
end