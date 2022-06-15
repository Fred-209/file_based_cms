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
    assert_includes response_body, "history.txt/edit"
    assert_includes response_body, 'changes.txt/edit'
    assert_includes response_body, 'about.md/edit'
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

  def test_render_markdown
    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response['Content-Type']
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_edit_document
    get "/history.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, 'Edit contents of history.txt:'
    

  end

  def test_update_document
    post "/changes.txt", content: "new content"

    assert_equal 302, last_response.status

    get last_response['Location']

    assert_includes last_response.body, "changes.txt has been updated"

    get "/changes.txt"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end