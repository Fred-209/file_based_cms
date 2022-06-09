require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

configure do 
  enable :sessions
end

before do 
  @files = Dir.glob(root + "/data/*").map do |file| 
    File.basename(file)
  end
end

get "/" do 
    
  erb :index, layout: :layout
end

get "/:filename" do 

  @file_name = params[:filename]

  if @files.include?(@file_name)
    @file = File.read(root + "/data/" + @file_name)
    headers['Content-Type'] = 'text/plain'
    @file
  else 
    session[:error] = "#{@file_name} does not exist."
    erb :index, layout: :layout
    # redirect "/"
  end
end
