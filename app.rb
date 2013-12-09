require "sinatra"
require "sinatra/activerecord"
require "digest/md5"
require "./sinatra/clear"
require "sinatra/flash"

Dir.glob("./models/*.rb") do |rb_file|
  require "#{rb_file}"
end

set :database, "sqlite3:///db/blog.sqlite3"
set :sessions, true


get "/" do 
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

#POSTS
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

get "/posts/:id" do 
  @post = Post.find(params[:id])
  erb :"posts/show"
end

get "/posts/:id/edit" do 
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
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
  @post = Post.find(params[:id])
  @post.comments.each do |comment|
    comment.destroy
  end
  @post = Post.find(params[:id]).destroy
  redirect "/"
end

#COMMENTS
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

delete "/posts/:id/comments/:comment_id" do
  page = params[:id].to_s
  @comment = Comment.find(params[:comment_id]).destroy
  redirect "/posts/"+page
end

#USERS
get '/register' do 
  erb :"pages/register"
end

post '/register' do 
  flash[:registration_error] = nil
  @user = User.new(params[:user])
  if @user.save
    redirect "/auth/login"
  else
    flash.now[:registration_error] = "Something wrong. Check it twice and try again."
    erb :"pages/register"
  end
end

#SESSIONS
get '/auth/login' do 
  erb :"/pages/login"   
end

post '/auth/login' do 
  flash[:error] = nil
  @user = User.find_by_email(params[:email])
  if @user && @user.password == Digest::MD5.hexdigest(params[:password])
    session[:user] = @user
    redirect "/"
  else
    flash.now[:error] = "Incorrect email or password. Please try again."
    redirect "/auth/login"
  end
end

get "/about_me" do 
  @title = "About Me"
  @user = session[:user]
  erb :"pages/about_me"
end

get '/auth/logout' do 
  session[:user] = nil
  redirect '/'
end