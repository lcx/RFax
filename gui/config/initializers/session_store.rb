# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_gui_session',
  :secret      => 'b904a9566a6d427d0d1547485d8ca43511eecf873145d2c40e0188c1137234779629112213bf4c5ae80c11ccb30fdfc9a9fe97122d00f016ea2946496a5d9a93'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
