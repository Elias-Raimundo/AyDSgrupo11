require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/reloader' if Sinatra::Base.environment == :development
require 'yaml'
require 'active_record'
require 'erb'
require 'logger'
require 'bigdecimal'
require 'bcrypt'


db_config = YAML.load_file('config/database.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])

Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require_relative file }

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

  # Procesa el formulario de registro (datos de usuario) y crea el usuario
  post '/final-signup' do
    # Recupera los datos del paso 1
    signup_data_step1 = session[:signup_data_step1]

    # Si no hay datos del Paso 1 en la sesión, hay un problema o el usuario intentó saltarse pasos
    unless step1_data
      @error = 'Error: Datos del primer paso de registro no encontrados.'
      return erb :signup1 # O una página de error
    end

    user_params = step1_data.merge(
      email: params[:email],
      password: params[:password],
      name: "#{step1_data[:nombre]} #{step1_data[:apellido]}",
      dni: step1_data[:dni],
      telefono: step1_data[:telefono]
    )
    # Crea el usuario en la base de datos
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id # Guarda el ID del usuario en la sesión
      session.delete(:signup_data_step1)
      redirect '/welcome' # Redirige a la página de bienvenida
    else
      @error = user.errors.full_messages.join(', ')
      erb :signup2 # Muestra el formulario de registro nuevamente con errores
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
