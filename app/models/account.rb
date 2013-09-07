require 'bcrypt'
require 'openssl'

class Account < ActiveRecord::Base
  attr_accessible :HashedUser, :HashedPass, :Salt

  def self.pass_is_good(pass,username)
  	@accounts = Account.where(:HashedUser => username)
  	@user = @accounts[0]
  	hashed_pass = BCrypt::Password.new @user[:HashedPass]
  	hashed_pass == pass
  end

  def self.pass_is_good_and_verified(pass,username)
  	@accounts = Account.where(:HashedUser => username)
  	@user = @accounts[0]
  	hashed_pass = BCrypt::Password.new @user[:HashedPass]
  	hashed_pass == pass
  end

  def self.pass_hash(pass)
  	hashed_pass = BCrypt::Password.new pass
	  return hashed_pass
  end


  def self.new_hashed_pass(pass)
  	hashed_pass = BCrypt::Password.create pass
  	return hashed_pass.to_s
  end

  def self.account_exists(username)
  	user = Account.where(:HashedUser => username)
  	!user.empty?
  end

  def self.generate_salt
  	return BCrypt::Engine.generate_salt.to_s
  end

  def self.hashed_user(username)
    keyed_user = username + ENV['ONIONS_AES']
    return OpenSSL::Digest::SHA256.new(keyed_user).hexdigest
  end

  def self.aes_key(username,pass,salt)
    return OpenSSL::PKCS5.pbkdf2_hmac_sha1((pass+username), salt, 20000, 16).unpack('H*')[0]
  end
end
