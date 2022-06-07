require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

get "/" do 
  @files = Dir.glob(root + "/data/*").map do |file| 
    File.basename(file)
  end
  
  erb :index, layout: :layout
end

get "/:filename" do 

  @file_name = params[:filename]
  @file = File.read(root + "/data/" + @file_name)
  
  headers['Content-Type'] = 'text/plain'
  @file
end
