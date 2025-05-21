# AyDSgrupo11
Virtual Wallet VAULT
Grupo 11 - Calcagno Mateo, Bessone Nicolas, Orlando Valentina Pilar, Raimundo Elias Santiago

#Descripción
Esta aplicación permite a los usuarios gestionar su dinero de forma digital. Se pueden realizar operaciones como ingresar, transferir y sacar dinero, consultar movimientos/actividad y administrar cuentas de forma segura y sencilla. Simula un sistema basico de cuentas, usuarios y transacciones, usando ActiveRecord, SQLite y Docker.

#Tecnologias
Ruby(con ActiveRecord)
Docker
SQLite3
Rake + Bundler

#Instalación (con Docker)
1. Clonar el repositorio:
git clone -b master https://github.com/Elias-Raimundo/AyDSgrupo11.git
cd AyDSgrupo11

2. Construir la imagen de Docker:
docker build -t aydsgrupo11 .

3. Crear y migrar la base de datos:
docker run -it --rm -v "$PWD":/app -w /app vault_app bash
bundle exec rake db:create
bundle exec rake db:migrate
exit

4. Ejecutar la app:
docker run -p 8000:8000 aydsgrupo11

Visitar: http://localhost:8000




