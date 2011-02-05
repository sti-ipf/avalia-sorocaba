# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_compreender2_session',
  :secret      => '3404c75f5c8ce68eec8ee1333adbee1da560b9eadee336d3e40a5e5c28885234280dc10da71a33231f702c222880f35d6293afd1ed7e5864f843209006bbbf02'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
