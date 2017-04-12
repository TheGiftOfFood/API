require 'sinatra'

helpers do
  def timecheck(stamp)
    if Time.now < Time.at(stamp)
      return true
    end
    return false
  end

  def tokensplit(token)
    index = token.rindex('.')
    authtoken = token[0,index]
    timestamp = token[index+1..-1].to_i
    return [authtoken,timestamp]
  end

  def tokenauth(env)
    token = tokensplit(env['HTTP_AUTHORIZATION'])
    if User.count(:token => env['HTTP_AUTHORIZATION']) < 1
      return [403, 'No user found with that token']
    elsif !timecheck(token[1])
      @user = User.first(:token => env['HTTP_AUTHORIZATION'])
      @user.generate_token!
      return [401, 'Token has expired. Please login again']
    end
    true
  end
end
