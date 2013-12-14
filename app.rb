require "sinatra"
require "sinatra/activerecord"
require "sinatra/flash"
require 'yaml'
require "digest/md5"
require "./helpers/helper.rb"

Dir.glob("./models/*.rb") do |rb_file|
  require "#{rb_file}"
end

ActiveRecord::Base.establish_connection(YAML.load(File.open("./config.yml"))) 
#set :database, "postgresql:///db/blog" #Перенести в yaml файл
set :sessions, true

helpers Helper

get "/" do 
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

error 403 do
  "Access forbidden. Permission denied"
end

["/posts/new", "/posts/*/edit", "/posts/*/comments","/posts/*/comments/*","/auth/logout","/about_me"].each do |path|
  before path do
    unless is_user_logged_on?
      halt 403
    end
  end
end

before '/auth/login' do
  if is_user_logged_on?
    halt 401, "Hey! Sign out first!"
  end
end

#POSTS

get "/posts/new" do 
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end

post "/posts/new" do  
  @post = Post.new(params[:post])
  @post.user = session[:user]
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
  if is_belong_to_user?(@post)
    erb :"posts/edit"
  else
    halt 403
  end
end

put "/posts/:id/edit" do 
  @post = Post.find(params[:id])
  if @post.update_attributes(params[:post])||is_belong_to_user?(@post)
    redirect "/posts/#{@post.id}"
  else
    erb :"posts/edit"
  end
end
 
delete "/posts/:id/edit" do 
  @post = Post.find(params[:id])
  if is_belong_to_user?(@post)
    @post.destroy
    redirect "/"
  else
    halt 403
  end
end

#COMMENTS

post "/posts/:id/comments" do 
  @comment = Comment.new(
    body: params[:comment_body],
    user_id: session[:user].id,
    post_id: params[:id]
    )
  if @comment.save
    redirect "posts/#{@comment.post_id}"
  else
    erb :"pages/show"
  end
end

delete "/posts/:id/comments/:comment_id" do
  @comment = Comment.find(params[:comment_id])
  if is_belong_to_user?(@comment)
    @comment.destroy
    redirect "/posts/#{params[:id].to_s}"
  else
    halt 403
  end
end

#USERS
get '/register' do 
  erb :"pages/register"
end

post '/register' do 
  @user = User.new(params[:user])
  if @user.save
    redirect "/auth/login"
  else
    erb :"pages/register"
  end
end

#SESSIONS
get '/auth/login' do 
  erb :"/pages/login"   
end

post '/auth/login' do 
  @user = User.find_by_email(params[:email])
  if @user && @user.auth(params[:password])
    session[:user] = @user
    redirect "/"
  else
    flash[:error] = "Incorrect email or password. Please try again."
    redirect "/auth/login"
  end
end

get "/about_me" do 
  @user = session[:user]
  erb :"pages/about_me"
end

get '/auth/logout' do 
  session[:user] = nil
  redirect '/'
end