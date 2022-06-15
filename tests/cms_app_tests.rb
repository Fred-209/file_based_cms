ENV["RACK_ENV"] = "test"


require "minitest/autorun"
require "rack/test"
require "fileutils"

require_relative "../cms"

class CmsAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def test_index

    create_document("history.txt")
    create_document("changes.txt")
    create_document("about.md")

    get "/"
    response_body = last_response.body

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes response_body, "history.txt/edit"
    assert_includes response_body, 'changes.txt/edit'
    assert_includes response_body, 'about.md/edit'
  end

  def test_page_content
    create_document("history.txt", "2003 - Ruby 1.8 released.")

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
    create_document("about.md", "# Ruby is...")

    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response['Content-Type']
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_edit_document
    create_document("history.txt", "<textarea")

    get "/history.txt/edit"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
  end

  def test_update_document
    create_document("changes.txt")

    post "/changes.txt", content: "new content"

    assert_equal 302, last_response.status

    get last_response['Location']

    assert_includes last_response.body, "changes.txt has been updated"

    get "/changes.txt"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end
end