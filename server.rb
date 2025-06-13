require_relative 'config/environment'

require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'yaml'
require 'active_record'
require 'erb'
require 'logger'
require 'bigdecimal'
require 'bcrypt'

class App < Sinatra::Application
  set :public_folder, 'public'

  configure :development do
    register Sinatra::Reloader
    after_reload do
      puts 'Reloaded...'
    end
  end

  set :views, File.expand_path('../views', __FILE__)
   # Activa sesiones (para mantener al usuario logueado)
  enable :sessions


#-------- RUTAS DE REGISTRO EN DOS PASOS ---------
  # Paso 1: Muestra el formulario inicial (datos personales)
  get '/signup' do
    erb :signup
  end  

  # Procesa el formulario de registro
  post '/signup2' do
    session[:signup_data_step1] = {
      nombre: params[:nombre],
      apellido: params[:apellido],
      dni: params[:dni],
      telefono: params[:telefono]
    }

    redirect '/signup2'
  end

  # Paso 2: Muestra el formulario de registro (datos de usuario)
  get '/signup2' do
    unless session[:signup_data_step1]
      # Si no hay datos del paso 1, redirigimos al inicio del registro
      redirect '/signup'
    end

    erb :signup2

  end

  post '/' do
    step1_data = session[:signup_data_step1]
  
    unless step1_data
      @error = 'Error: Datos del primer paso de registro no encontrados.'
      return erb :signup
    end
  
    ActiveRecord::Base.transaction do
      # Crear la persona
      person = Person.create!(
        name: step1_data[:nombre],
        surname: step1_data[:apellido],
        dni: step1_data[:dni],
        phone_number: step1_data[:telefono]
      )
  
      # Crear el usuario
      user = User.create!(
        email: params[:email],
        password: params[:password],
        person: person
      )
  
      session[:user_id] = user.id
      session.delete(:signup_data_step1)
      redirect '/'
    rescue ActiveRecord::RecordInvalid => e
      @error = e.record.errors.full_messages.join(', ')
      erb :signup2
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

  get '/autenticacionEmail' do
    erb :autenticacionEmail
  end 

  get '/' do
    erb :welcome
  end
end
