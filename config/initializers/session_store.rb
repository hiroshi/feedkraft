# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_feedkraft_session',
  :expire_after => 1.years,
  :secret      => '37022b3103bddaa757d9663da286ab13d360aa9fa3dca0c181018f46ccfe3b34fe15fbe88238f138933837b8ce85e118db6762c77dd74b0ae36e1b9d6dc70488'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
