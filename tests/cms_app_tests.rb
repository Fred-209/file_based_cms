ENV["RACK_ENV"] = "test"


require "minitest/autorun"
require "rack/test"

require_relative "../cms.rb"

class CmsAppTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    puts last_response.body
    assert_equal 200, last_response.status
    
    # assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
  end
end