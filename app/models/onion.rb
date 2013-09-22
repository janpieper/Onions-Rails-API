require 'base64'
require 'openssl'

class Onion < ActiveRecord::Base
  attr_accessible :HashedInfo, :HashedTitle, :HashedUser

  # Take Onions from DB and decrypt them all after a User logs in
  def self.decrypted_onions_with_key(onions,key)
  	if onions && key
  		onions.each do |o|
  			title = Base64.decode64(o.HashedTitle)
  			info = Base64.decode64(o.HashedInfo)
  			title = Onion.aes256_decrypt(key,title)
  			info = Onion.aes256_decrypt(key,info)
  			o.HashedTitle = title
  			o.HashedInfo = info
  		end
  	end

  	return onions
  end

  # Encrypt an Onion
  def self.aes256_encrypt(key, data)
	key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
	aes = OpenSSL::Cipher.new('AES-256-CBC')
	aes.encrypt
	aes.key = key
	aes.update(data) + aes.final
  end

  # Decrypt an Onion
  def self.aes256_decrypt(key, data)
	key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
	aes = OpenSSL::Cipher.new('AES-256-CBC')
	aes.decrypt
	aes.key = key
	aes.update(data) + aes.final
  end

end
