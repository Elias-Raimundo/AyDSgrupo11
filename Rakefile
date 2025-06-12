require 'active_record'
require 'yaml'
require 'rake'

# Carga la configuración de base de datos según el entorno
def db_config(env)
  configs = YAML.load(File.read('config/database.yml'), aliases: true)
  configs[env] or raise "No database config for '#{env}'"
end

# Establece la conexión con ActiveRecord
def establish_connection(env)
  ActiveRecord::Base.establish_connection(db_config(env))
end

namespace :db do
  desc 'Crear la base de datos (para SQLite solo crea el archivo)'
  task :create, [:env] do |t, args|
    env = args[:env] || 'development'
    config = db_config(env)
    if config['adapter'] == 'sqlite3'
      db_path = config['database']
      unless File.exist?(db_path)
        FileUtils.mkdir_p(File.dirname(db_path))
        FileUtils.touch(db_path)
        puts "Archivo de DB creado en #{db_path}"
      else
        puts "Archivo de DB ya existe en #{db_path}"
      end
    else
      # Si usás otro DB, acá podés agregar lógica para crear la DB
      puts "Crear DB para #{config['adapter']} no implementado."
    end
  end

  desc 'Ejecutar migraciones pendientes'
  task :migrate, [:env] do |t, args|
    env = args[:env] || 'development'
    establish_connection(env)
    migrations_path = File.expand_path('db/migrate', __dir__)
    ActiveRecord::MigrationContext.new(migrations_path).migrate
  end

  desc 'Borrar base de datos (elimina archivo SQLite)'
  task :drop, [:env] do |t, args|
    env = args[:env] || 'development'
    config = db_config(env)
    if config['adapter'] == 'sqlite3'
      db_path = config['database']
      if File.exist?(db_path)
        File.delete(db_path)
        puts "Archivo de DB borrado: #{db_path}"
      else
        puts "Archivo de DB no existe: #{db_path}"
      end
    else
      puts "Drop DB para #{config['adapter']} no implementado."
    end
  end
end 