require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"

root = File.expand_path("..", __FILE__)

configure do 
  enable :sessions
  set :session_secret, "secret"
end


def load_file_content(path)
  content = File.read(path)

  case File.extname(path)
  when '.md' 
    erb render_markdown(content)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  end

end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def data_path
  if ENV['RACK_ENV'] == 'test'
    File.expand_path("../tests/data", __FILE__)
  else
    File.expand_path("../data", __FILE__)
  end
end


# Index page
get "/" do 
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path| 
    File.basename(path)
  end

  erb :index, layout: :layout
end

# Show contents of file
get "/:filename" do 

  @file_name = params[:filename]
  file_path = File.join(data_path, @file_name)

  if File.file?(file_path)
    load_file_content(file_path)
  else 
    session[:message] = "#{@file_name} does not exist."
    redirect "/"
  end
end

 # Edit a file
get "/:filename/edit" do
  @file_name = params[:filename]
  @file_path = File.join(data_path, @file_name)
  @content =File.read(@file_path)
  

  erb :edit_file, layout: :layout
end

post "/:filename" do 
  file_path = File.join(data_path, + params[:filename])
  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end