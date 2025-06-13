require 'mail'

options = {
  address: "smtp.gmail.com",
  port: 587,
  user_name: 'vaultvirtualwallet@gmail.com',
  password: 'ubjnknchbrpnsdnf',
  authentication: 'plain',
  enable_starttls_auto: true
}

Mail.defaults do
  delivery_method :smtp, options
end