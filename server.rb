require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'yaml'
require 'active_record'
require 'erb'
require 'logger'
require 'bigdecimal'
#require_relative 'file'


db_config = YAML.load_file('config/database.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require_relative file }

class App < Sinatra::Application
  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  set :views, File.expand_path('../views', __FILE__)
   # Activa sesiones (para mantener al usuario logueado)
  enable :sessions



  # Ruta para mostrar el formulario de registro
  get '/signup' do
    erb :signup
  end  

  # Procesa el formulario de registro
  post '/signup' do
    user = User.new(
      name: params[:name],
      email: params[:email],
      password: params[:password] # bcrypt lo convierte en password_digest
    )

    if user.save
      session[:user_id] = user.id
      redirect '/welcome'
    else
      @error = user.errors.full_messages.join(', ')
      erb :signup
    end
  end

  # Muestra el formulario de login
  get '/login' do
    erb :login
  end
  # Procesa el login
  post '/login' do
    user = User.find_by(email: params[:email])

    # Verifica que el usuario exista y la contraseña sea válida
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/welcome'
    else
      @error = 'Email o contraseña incorrectos'
      erb :login
    end
  end


  get '/' do
    erb :welcome
  end
end
