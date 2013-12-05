require "sinatra"
require "sinatra/activerecord"
require "digest/md5"

Dir.glob("./models/*.rb").each do |rb_file|
 	require "#{rb_file}"
end

set :database, "sqlite3:///db/blog.sqlite3"
set :sessions, true


helpers do
  def pretty_date(time)
   time.strftime("%d %b %Y")
  end

  def post_show_page?
    request.path_info =~ /\/posts\/\d+$/
  end

end

get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end


get "/posts/new" do
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end
 
post "/posts" do
  @post = Post.new(params[:post])
  @post.user_id = session[:cur_user].id
  if @post.save
    redirect "posts/#{@post.id}"
  else
    erb :"posts/new"
  end
end

get "/posts/:id" do
  @post = Post.find(params[:id])
  @comments = Comment.where("post_id = ?", params[:id])
  erb :"posts/show"
end
 
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end

post "/posts/:id" do
  @comment = Comment.new
  @comment.body = params[:comment_body]
  @comment.user_id = session[:cur_user].id
  @comment.post_id = params[:id]
  @comment.save
  redirect "posts/#{@comment.post_id}"
end

put "/posts/:id" do
  @post = Post.find(params[:id])
  if @post.update_attributes(params[:post])
    redirect "/posts/#{@post.id}"
  else
    erb :"posts/edit"
  end
end
 
delete "/posts/:id" do
  @post = Post.find(params[:id]).destroy
  redirect "/"
end

get "/about_me" do
  @title = "About Me"
  @user = session[:cur_user]
  erb :"pages/about_me"
end

get '/register' do
  erb :"pages/register"
end

post '/register' do
  @user = User.new
  @user.name = params[:username]
  @user.password = Digest::MD5.hexdigest(params[:password])
  @user.email = params[:email]
  if @user.save
  	redirect "/"
  else
  	erb :"pages/register"
  end
end

get '/auth/login' do
  erb :"/pages/login"   
end

post '/auth/login' do
  @user = User.find_by email: params[:email]
  if @user && @user.password == Digest::MD5.hexdigest(params[:password])
    session[:cur_user] = @user
    redirect "/"
  else
  	#сюда надо бы как-то выплюнуть ошибку авторизации
    redirect "/auth/login"
  end  	
end

post '/auth/logout' do
  session[:cur_user] = nil
  redirect '/'
end