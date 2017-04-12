require 'sinatra'
require 'bcrypt'
require 'docdsl'
require 'json'

register Sinatra::DocDsl

documentation 'Sign up a new user' do
  param :email, 'Users email'
  param :password, 'Users password'
  status 201, 'User created'
  status 409, 'User with this email already exists'
  status 500
end
post '/signup' do
  if User.count(:email => params[:email]) > 0
    halt 409, 'User with this email already exists'
  end
  @user = User.create(:email => params[:email],:password => params[:password])
  if @user.saved?
    status 201
  else
    status 500
  end
end

documentation 'Login a user' do
  param :email, 'Users email'
  param :password, 'Users password'
  response 'Authentication token to be used with future requests', {:token => 'TOKEN' }
  status 200, 'Logged in'
  status 401, 'Wrong password'
  status 404, 'No user found'
end
post '/login' do
  if User.count(:email => params[:email]) < 0
    halt 404, 'No user with that email found'
  end
  @user = User.first(:email => params[:email])
  @user_hash = BCrypt::Password.new(@user.password)
  if @user_hash == params[:password] then
    @user.generate_token!
    status 200
    {:token => @user.token}.to_json
  else
    status 401
  end
end

documentation 'Find a particular user' do
  param :id, 'User ID'
  header 'Authorization', 'Users Auth Token'
  response 'User in JSON', {:id => 1, :email => 'test@gmail.com', :password => 'pass123', :token => 'TOKEN'}
  status 200
  status 401
  status 403
  status 404
end
get '/finduser' do
  ta = tokenauth(env)
  if !(ta === true)
    halt ta[0], ta[1]
  end
  if User.count(:id => params[:id]) < 1
    halt 404, 'Cant find User!'
  end
  @user = User.first(:id => params[:id])
  status 200
  body @user.to_json
end
