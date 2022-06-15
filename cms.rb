require "sinatra"
require "sinatra/reloader" if development?
require "sinatra/content_for"
require "tilt/erubis"
require "redcarpet"
require "fileutils"

root = File.expand_path("..", __FILE__)

configure do 
  enable :sessions
  set :session_secret, "secret"
end

def create_document(name, content = "")
  File.open(File.join(data_path, name), "w") do |file|
    file.write(content)
  end
end

def load_file_content(path)
  content = File.read(path)

  case File.extname(path)
  when '.md' 
    erb render_markdown(content)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  else
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

def valid_file_name?(file_name)
  file_name.length > 0
end

# Index page
get "/" do 
  pattern = File.join(data_path, "*")
  @files = Dir.glob(pattern).map do |path| 
    File.basename(path)
  end

  erb :index, layout: :layout
end

# Create a document form
get "/new" do

  erb :new_document
end

# Submit new document creation
post "/create" do 
  file_name = params[:filename].strip
  
  if valid_file_name?(file_name)
    create_document(file_name)
    session[:message] = "#{file_name} was created."

    redirect "/"
  else
    session[:message] = "A name is required."
    status 422
    erb :new_document
  end
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

# Update contents of a file
post "/:filename" do 
  file_path = File.join(data_path, + params[:filename])
  File.write(file_path, params[:content])

  session[:message] = "#{params[:filename]} has been updated."
  redirect "/"
end

# Delete a file
post "/:filename/delete" do 
  file_name = File.join(data_path, params[:filename])
  FileUtils.rm_rf(file_name)
  
  session[:message] = "#{File.basename(file_name)} was deleted."
  redirect "/"
end

