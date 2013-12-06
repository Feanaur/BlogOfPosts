require "sinatra"
require "sinatra/activerecord"
require "digest/md5"
require "./sinatra/clear"
require "sinatra/flash"
#before filters 
Dir.glob("./models/*.rb") do |rb_file|
  require "#{rb_file}"
end

set :database, "sqlite3:///db/blog.sqlite3"
set :sessions, true

get "/posts/new" do 
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end
 
post "/posts" do 
  @post = Post.new(params[:post])
  @post.user_id = session[:user].id
  if @post.save
    redirect "posts/#{@post.id}"
  else
    erb :"posts/new"
  end
end

post '/register' do
  @user = User.new(
    name: params[:username],
    password: params[:password],
    email: params[:email])

  if @user.save
    redirect "/"
  else
    erb :"pages/register"
  end
end

post '/auth/login' do
  @user = User.find_by_email(params[:email])
  if @user && @user.password == Digest::MD5.hexdigest(params[:password])
    session[:user] = @user
    redirect "/"
  else
    flash[:error] = "Incorrect email or password. Please try again."
    redirect "/auth/login"
  end
end

get "/" do 
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

get "/posts/:id" do
  @post = Post.find(params[:id])
  erb :"posts/show"
end
 
get "/about_me" do
  @title = "About Me"
  @user = session[:user]
  erb :"pages/about_me"
end

get '/register' do
  erb :"pages/register"
end

get '/auth/login' do
  erb :"/pages/login"   
end
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end

post "/posts/:id/comments" do
  @comment = Comment.new(
    body: params[:comment_body],
    user_id: session[:user].id,
    post_id: params[:id])
  if @comment.save
    redirect "posts/#{@comment.post_id}"
  else
    erb :"pages/register"
  end
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

post '/auth/logout' do 
  session[:user] = nil
  redirect '/'
end