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
    render_markdown(content)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  end

end

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
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
    load_file_content(file_path)
    # @file = File.read(file_path)

    # if @file_name.end_with?('.md')
    #   render_markdown(@file)
    # else 
    #   headers['Content-Type'] = 'text/plain'
    #   @file
    # end
  else 
    session[:message] = "#{@file_name} does not exist."
    redirect "/"
  end
end
