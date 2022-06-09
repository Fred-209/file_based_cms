require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"

root = File.expand_path("..", __FILE__)

configure do 
  enable :sessions
  set :session_secret, "secret"
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
  file_path = root + "/data/" + @file_name

  if File.file?(file_path)
    headers['Content-Type'] = 'text/plain'
    @file = File.read(file_path) 
  else 
    session[:message] = "#{@file_name} does not exist."
    redirect "/"
  end
end
