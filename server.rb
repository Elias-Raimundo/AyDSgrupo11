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
require 'mail'
require_relative './config/mail_config'

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
  helpers do
    def generate_unique_cvu
        loop do
          cvu = Array.new(22) { rand(0..9) }.join
          break cvu unless Account.exists?(cvu: cvu)
        end
      end

  def generate_unique_alias
    words = %w[sol rio luna casa mar azul perro gato nube flor monte cielo fuego aire roca barco auto moto coche avión plaza puerta planeta balde hoja manta] 
    loop do
      alias_str = 3.times.map { words.sample }.join('.')
      break alias_str unless Account.exists?(account_alias: alias_str)
    end
  end

  def formatted_money(amount)
      sprintf('%.2f', amount).gsub(/(\d)(?=(\d{3})+\.)/, '\\1,')
  end
end

#-------- RUTAS DE REGISTRO EN DOS PASOS ---------
  # Paso 1: Muestra el formulario inicial (datos personales)
  get '/signup' do
    erb :signup
  end  

  # Procesa el formulario de registro
  post '/signup2' do
      if Person.exists?(dni: params[:dni])
        @error = "El DNI ya está registrado."
        return erb :signup
    end
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
    redirect '/signup' unless session[:signup_data_step1]
    erb :signup2
  end

  post '/' do
    step1_data = session[:signup_data_step1]
  
    unless step1_data
      @error = 'Error: Datos del primer paso de registro no encontrados.'
      return erb :signup
    end

    session[:signup_data_step2] = {
      email: params[:email],
      password: params[:password]
    }

    pin = rand(100000..999999).to_s
    session[:confirmation_pin] = pin
    session[:pin_expiry] = Time.now + 5 * 60

    email_destinatario = params[:email]
    require './config/mail_config'
    Mail.deliver do
      to email_destinatario
      from 'vaultvirtualwallet@gmail.com'
      subject 'Tu PIN de confirmación de Vault'
      body "Tu código de verificación es: #{pin}"
    end
    redirect '/autenticacionEmail'
  end

    
  post '/confirmar-pin' do
  pin = params[:pin]

  if pin != session[:confirmation_pin]
    @error = "El PIN ingresado es incorrecto."
    return erb :autenticacionEmail
  end

  if Time.now > session[:pin_expiry]
    @error = "El PIN expiró. <a href='/reenviar-pin'>Reenviar</a>"
    return erb :autenticacionEmail
  end

  


      step1_data = session[:signup_data_step1]
      step2_data = session[:signup_data_step2]

  if step1_data.nil? || step2_data.nil?
    return "Error: datos incompletos. <a href='/signup'>Comenzar de nuevo</a>"
  end

  begin
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
        email: step2_data[:email],
        password: step2_data[:password],
        person: person
      )

      Account.create!(
      user: user,
      cvu: generate_unique_cvu,
      account_alias: generate_unique_alias,
      balance: 0
      )
      session[:user_id] = user.id
    end
      
    session.delete(:signup_data_step1)
    session.delete(:signup_data_step2)
    session.delete(:confirmation_pin)
    session.delete(:pin_expiry)

    redirect '/'
    rescue ActiveRecord::RecordInvalid => e
      return "Error al registrar: #{e.record.errors.full_messages.join(', ')}"
    end
  end

   # Reenviar PIN
  get '/reenviar-pin' do
    email_destinatario = session.dig(:signup_data_step2, :email)
    redirect '/signup2' unless email_destinatario

    pin = rand(100000..999999).to_s
    session[:confirmation_pin] = pin
    session[:pin_expiry] = Time.now + 5 * 60

    require './config/mail_config'
    Mail.deliver do
      to email_destinatario
      from 'vaultvirtualwallet@gmail.com'
      subject 'Tu PIN de confirmación de Vault'
      body "Tu código de verificación es: #{pin}"
    end

    redirect '/autenticacionEmail'
  end

  get '/reenviar-pin-contrasena' do
  email_destinatario = session[:recovery_email]
  redirect '/olvideMiContrasena' unless email_destinatario

  pin = rand(100000..999999).to_s
  session[:recovery_pin] = pin
  session[:recovery_pin_expiry] = Time.now + 5 * 60

  require './config/mail_config'
  Mail.deliver do
    to email_destinatario
    from 'vaultvirtualwallet@gmail.com'
    subject 'Tu PIN de recuperación de Vault'
    body "Tu código de verificación es: #{pin}"
  end

  redirect '/verificarPinRecuperacion'
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
      redirect '/principal'
    else
      @error = 'Email o contraseña incorrectos'
      erb :login
    end
  end

  get '/autenticacionEmail' do
    erb :autenticacionEmail
  end 

  get '/olvideMiContrasena' do
    erb :olvideMiContrasena
  end

  post '/enviarPinRecuperacion' do
    user = User.find_by(email: params[:email])
    
    if user
      pin = rand(100000..999999).to_s
      session[:recovery_email] = user.email
      session[:recovery_pin] = pin
      session[:recovery_pin_expiry] = Time.now + 5 * 60

      Mail.deliver do
        to user.email
        from 'vaultvirtualwallet@gmail.com'
        subject 'Recuperación de contraseña Vault'
        body "Tu código de recuperación es: #{pin}"
      end

      redirect '/verificarPinRecuperacion'
    else
      @error = "No se encontró un usuario con ese email."
      erb :olvideMiContrasena
    end
  end

  get '/verificarPinRecuperacion' do
    erb :verificarPinRecuperacion
  end

  post '/verificarPinRecuperacion' do
    if params[:pin] == session[:recovery_pin] && Time.now < session[:recovery_pin_expiry]
      redirect '/nuevaContrasena'
    else
      @error = "PIN inválido o expirado."
      erb :verificarPinRecuperacion
    end
  end

  get '/nuevaContrasena' do
    erb :nuevaContrasena
  end

  post '/nuevaContrasena' do
    user = User.find_by(email: session[:recovery_email])

    if user
      user.password = params[:password]
      if user.save
        session.delete(:recovery_email)
        session.delete(:recovery_pin)
        session.delete(:recovery_pin_expiry)
        redirect '/login'
      else
        @error = "Error al guardar la nueva contraseña."
        erb :nuevaContrasena
      end
    else
      @error = "Usuario no encontrado."
      erb :nuevaContrasena
    end
  end

  get '/' do
    erb :welcome
  end

  get '/ingresar' do
    redirect '/login' unless session[:user_id]
    @usuario = User.find(session[:user_id])
    erb :ingresar
  end

  post '/ingresar' do
    redirect '/login' unless session[:user_id]
  
    monto = params[:monto].to_f
    if monto <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :ingresar
    end
  
    user = User.find(session[:user_id])
    cuenta = user.account
  
    unless cuenta
      @error = "No se encontró cuenta para el usuario."
      return erb :ingresar
    end
  
    # En caso que balance sea nil, inicializar en 0
    cuenta.balance ||= 0
  
    ActiveRecord::Base.transaction do
      # Crear el ingreso en la tabla incomes
      ingreso = Income.new(
        amount: monto,
        source: "Depósito manual", # Cambiar por el origen real si corresponde
        user_id: user.id
      )
      
      unless ingreso.save
        @error = "Error al registrar el ingreso: #{ingreso.errors.full_messages.join(", ")}"
        raise ActiveRecord::Rollback
      end
  
      # Actualizar el balance de la cuenta
      cuenta.balance += monto
      unless cuenta.save
        @error = "Error al actualizar el balance."
        raise ActiveRecord::Rollback
      end
    end
  redirect '/principal'
  rescue => e
    @error ||= "Ocurrió un error inesperado: #{e.message}"
    erb :ingresar
  end

  get '/retirar' do
    redirect '/login' unless session[:user_id]
    @usuario = User.find(session[:user_id])
    erb :retirar
  end

  post '/retirar' do
    redirect '/login' unless session[:user_id]
  
    monto = params[:monto].to_f
    if monto <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :retirar
    end
  
    user = User.find(session[:user_id])
    cuenta = user.account
  
    unless cuenta
      @error = "No se encontró cuenta para el usuario."
      return erb :retirar
    end
  
    cuenta.balance ||= 0
  
    if monto > cuenta.balance
      @error = "Saldo insuficiente para realizar el retiro."
      return erb :retirar
    end
  
    ActiveRecord::Base.transaction do
      # Crear el retiro en la tabla withdrawals
      retiro = Withdrawal.new(
        amount: monto,
        reason: "Retiro manual", # Cambiar por la razón real si corresponde
        user_id: user.id
      )
  
      unless retiro.save
        @error = "Error al registrar el retiro: #{retiro.errors.full_messages.join(", ")}"
        raise ActiveRecord::Rollback
      end
  
      # Actualizar el balance de la cuenta
      cuenta.balance -= monto
      unless cuenta.save
        @error = "Error al actualizar el balance."
        raise ActiveRecord::Rollback
      end
    end
  
    redirect '/principal'
  rescue => e
    @error ||= "Ocurrió un error inesperado: #{e.message}"
    erb :retirar
  end

  # ---------- TRANSFERENCIAS ENTRE USUARIOS ----------
  get '/transferir' do
    redirect '/login' unless session[:user_id]
    erb :transferir
  end

  post '/transferir' do
    redirect '/login' unless session[:user_id]

    monto = params[:monto].to_f
    destino = params[:destino].strip

    if monto <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :transferir
    end

    origen_user = User.find(session[:user_id])
    cuenta_origen = origen_user.account

    cuenta_destino = Account.find_by(cvu: destino) || Account.find_by(account_alias: destino)

    if cuenta_destino.nil?
      @error = "No se encontró la cuenta de destino."
      return erb :transferir
    end

    if cuenta_origen.id == cuenta_destino.id
      @error = "No puedes transferirte a tu propia cuenta."
      return erb :transferir
    end

    if cuenta_origen.balance < monto
      @error = "Saldo insuficiente."
      return erb :transferir
    end

    begin
      Transaction.create!(
        source_account: cuenta_origen,
        target_account: cuenta_destino,
        amount: monto
      )
      @success = "Transferencia realizada con éxito."
      erb :transferir
    rescue => e
      @error = "Error en la transferencia: #{e.message}"
      erb :transferir
    end
  end

  get '/ahorros' do
    redirect '/login' unless session[:user_id]
    @usuario = User.find(session[:user_id])
    account = @usuario.account
    erb :ahorros
  end

  post '/ahorros' do
    redirect '/login' unless session[:user_id]
  
    amount = params[:amount].to_f
    name = params[:name].strip.capitalize
    user = User.find(session[:user_id])
    account = user.account
  
    if amount <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :ahorros
    end
  
    if name.empty?
      @error = "El motivo no puede estar vacío."
      return erb :ahorros
    end
  
    # Busca si ya existe un ahorro con el mismo nombre para la cuenta actual
    existing_ahorro = Saving.find_by(name: name, account: account)
  
    if existing_ahorro
      # Si existe, sumamos el nuevo monto al ahorro existente
      if account.balance < amount
        @error = "Saldo insuficiente para agregar a la reserva."
        return erb :ahorros
      end
  
      added_amount = amount
      existing_ahorro.amount += added_amount
      account.balance -= added_amount

      if existing_ahorro.save && account.save
        SavingTransaction.create!(
          account: account,
          name: existing_ahorro.name,
          amount: added_amount,
          transaction_type: 'Ingreso a reserva'
        )
        redirect '/principal'
      else
        @error = existing_ahorro.errors.full_messages.join(", ")
        erb :ahorros
      end
    else
      # Si no existe un ahorro con ese nombre, crea uno nuevo
      if account.balance < amount
        @error = "Saldo insuficiente."
        return erb :ahorros
      end
  
      ahorro = Saving.new(amount: amount, name: name, account: account)
      
  
      if ahorro.save && account.save
        SavingTransaction.create!(
          account: account,
          name: name,
          amount: amount,
          transaction_type: 'Ingreso a reserva'
        )
        redirect '/principal'
      else
        @error = ahorro.errors.full_messages.join(", ")
        erb :ahorros
      end
    end
  end
  
  # ---------- RETIRAR DINERO DE UNA RESERVA ----------
  get '/retirar_reserva' do
    redirect '/login' unless session[:user_id]

    @usuario = User.find(session[:user_id])
    @cuenta = @usuario.account
    @reservas = Saving.where(account: @cuenta)

    erb :retirar_reserva
  end

  post '/retirar_reserva' do
    redirect '/login' unless session[:user_id]

    user = User.find(session[:user_id])
    cuenta = user.account

    reserva = Saving.find_by(id: params[:reserva_id], account: cuenta)
    monto = params[:amount].to_f

    if reserva.nil?
      @error = "Reserva no encontrada."
      return erb :retirar_reserva
    end

    if monto <= 0
      @error = "El monto debe ser mayor a 0."
      return erb :retirar_reserva
    end

    if monto > reserva.amount
      @error = "No tenés suficiente dinero en esa reserva."
      return erb :retirar_reserva
    end

    ActiveRecord::Base.transaction do
      withdrawn_amount = monto
      reserva.amount -= withdrawn_amount
    
      if reserva.amount <= 0.00001
        reserva.destroy! # La eliminas si queda en 0
      else
        reserva.save!
      end
    
      cuenta.balance += withdrawn_amount
      cuenta.save!
    
      SavingTransaction.create!(
        account: cuenta,
        name: reserva.name,
        amount: -withdrawn_amount,
        transaction_type: 'Retiro de reserva'
      )
    
  end


    redirect '/principal'
  rescue => e
    @error = "Error al retirar de la reserva: #{e.message}"
    @usuario = user
    @cuenta = cuenta
    @reservas = Saving.where(account: cuenta)
    erb :retirar_reserva
  end


    get '/principal' do
      redirect '/login' unless session[:user_id] # Verifica si el usuario está logueado
    
      @usuario = User.find(session[:user_id])
      @cuenta = @usuario.account
    
      unless @cuenta
        @error = "No se encontró cuenta para el usuario."
        return erb :error
      end
    
      # Traer ingresos y retiros del usuario
      @incomes = Income.where(user_id: @usuario.id).select(:amount, :source, :created_at)
      @withdrawals = Withdrawal.where(user_id: @usuario.id).select(:amount, :reason, :created_at)
    
      # Traer transacciones donde la cuenta es fuente o destino
      @transactions_as_source = Transaction.where(source_account_id: @cuenta.id)
      @transactions_as_target = Transaction.where(target_account_id: @cuenta.id)
    
      # Combinar actividades en un arreglo
      @activities = obtener_todas_las_actividades
      
      # Traer las reservas/ahorros asociados a la cuenta
      @reservas = Saving.where(account: @cuenta)

      erb :principal
    end

    get '/actividades' do
      @actividades = obtener_todas_las_actividades # Método para obtener todas las actividades
      erb :actividad
    end
  
    def obtener_todas_las_actividades
      if session[:user_id]
        user = User.find(session[:user_id])
        account = user.account
    
        incomes = Income.where(user_id: user.id).select(:amount, :source, :created_at)
        withdrawals = Withdrawal.where(user_id: user.id).select(:amount, :reason, :created_at)
        saving_transactions = SavingTransaction.where(account_id: account.id)

    
        # Precargamos las asociaciones para evitar N+1
        transactions_as_source = Transaction.includes(target_account: { user: :person })
                                           .where(source_account_id: account.id)
        transactions_as_target = Transaction.includes(source_account: { user: :person })
                                           .where(target_account_id: account.id)
    
        activities = (incomes.map do |income|
                        { type: 'Ingreso', amount: income.amount, details: income.source, date: income.created_at }
                      end +
                      withdrawals.map do |withdrawal|
                        { type: 'Retiro', amount: -withdrawal.amount, details: withdrawal.reason, date: withdrawal.created_at }
                      end +
                      saving_transactions.map do |saving_transaction|
                        {
                          type: saving_transaction.transaction_type,
                          amount: saving_transaction.amount,
                          details: "Reserva '#{saving_transaction.name}'",
                          date: saving_transaction.created_at
                        }
                      end +
                      transactions_as_source.map do |transaction|
                        target_person = transaction.target_account.user.person
                        {
                          type: 'Transferencia Enviada',
                          amount: -transaction.amount,
                          details: "A #{target_person.name} #{target_person.surname}",
                          date: transaction.created_at
                        }
                      end +
                      transactions_as_target.map do |transaction|
                        source_person = transaction.source_account.user.person
                        {
                          type: 'Transferencia Recibida',
                          amount: transaction.amount,
                          details: "De #{source_person.name} #{source_person.surname}",
                          date: transaction.created_at
                        }
                      end).sort_by { |activity| activity[:date] }.reverse
    
        return activities
      else
        return []
      end
    end

  get '/reserva' do 
    redirect '/login' unless session[:user_id]

    user = User.find(session[:user_id])
    cuenta = user.account

    unless cuenta
      @error = "No se encontró cuenta para el usuario."
      return erb :error
    end

    @ahorro_total = Saving.where(account_id: cuenta.id).sum(:amount)

    erb :reserva
  end

  get '/todas_las_reservas' do
    redirect '/login' unless session[:user_id]

    @usuario = User.find(session[:user_id])
    @cuenta = @usuario.account
    @reservas = Saving.where(account: @cuenta)

    erb :todas_las_reservas
  end

  #Cambiar Alias
  post '/actualizar_alias' do
  redirect '/login' unless session[:user_id]

  nuevo_alias = params[:nuevo_alias].strip.downcase
  cuenta = User.find(session[:user_id]).account

  if Account.where(account_alias: nuevo_alias).where.not(id: cuenta.id).exists?
    session[:error] = "El alias ya está en uso por otra cuenta."
  elsif nuevo_alias =~ /\A[a-z0-9\.]{3,30}\z/
    cuenta.account_alias = nuevo_alias
    if cuenta.save
      session[:success] = "Alias actualizado correctamente."
    else
      session[:error] = "Error al actualizar el alias."
    end
  else
    session[:error] = "Alias inválido. Solo letras, números y puntos. Mínimo 3 caracteres."
  end

  redirect '/principal'
end



  get '/logout' do
    session.clear
    redirect '/login'
  end

end


