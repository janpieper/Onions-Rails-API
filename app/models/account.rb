require 'bcrypt'
require 'openssl'

class Account < ActiveRecord::Base
  attr_accessible :HashedUser, :HashedPass, :Salt

  # Authenticate User/Pass
  def self.pass_is_good(pass,username)
    @accounts = Account.where(:HashedUser => username)
    @user = @accounts[0]
    hashed_pass = BCrypt::Password.new @user[:HashedPass]
    hashed_pass == pass
  end

  # Create new Hashed Password from a plaintext input
  def self.new_hashed_pass(pass)
    hashed_pass = BCrypt::Password.create pass
    return hashed_pass.to_s
  end

  # Determine if an acount exists in the Accounts Table
  def self.account_exists(username)
    user = Account.where(:HashedUser => username)
    !user.empty?
  end

  # Generate a random Salt
  def self.generate_salt
    return BCrypt::Engine.generate_salt.to_s
  end

  # Hash a plaintext username
  def self.hashed_user(username)
    keyed_user = username + ENV['ONIONS_AES']
    return OpenSSL::Digest::SHA256.new(keyed_user).hexdigest
  end

  # Generate an AES key using plaintext pass, user & Account.Salt
  def self.aes_key(username,pass,salt)
    return OpenSSL::PKCS5.pbkdf2_hmac_sha1((pass+username), salt, 20000, 16).unpack('H*')[0]
  end
end
