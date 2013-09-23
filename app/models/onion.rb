require 'base64'
require 'openssl'

class Onion < ActiveRecord::Base
  attr_accessible :HashedInfo, :HashedTitle, :HashedUser, :Title_Iv, :Info_Iv, :Title_AuthTag, :Info_AuthTag

  # Take Onions from DB and decrypt them all after a User logs in
  def self.decrypted_onions_with_key(onions,key)
  	if onions && key
      betaProblems = false
  		onions.each do |o|
        hash = Onion.decrypted_onion(key, o)
  			if hash[:BetaProblems]
          betaProblems = true
        end
  		end
  	end

  	return {:Onions => onions, :BetaProblems => betaProblems}
  end

  # Encrypt data
  def self.aes256_encrypt(key, data)
    key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
    aes = OpenSSL::Cipher::AES.new(256, :CBC)
    aes.encrypt
    aes.key = key
    new_iv = aes.random_iv
    encrypted_data = aes.update(data) + aes.final
    auth_tag = Digest::SHA256.digest(ENV['AUTH_TAG'] + encrypted_data)
    # return encrypted data, the iv, and the authentication info
    return {:EncryptedData => Base64.encode64(encrypted_data), :Iv => Base64.encode64(new_iv), :AuthTag => Base64.encode64(auth_tag)}
  end

  # Decrypt data
  def self.aes256_decrypt(key, data, iv, auth_tag)
    if Digest::SHA256.digest(ENV['AUTH_TAG'] + data) == auth_tag
      key = Digest::SHA256.digest(key) if(key.kind_of?(String) && 32 != key.bytesize)
      aes = OpenSSL::Cipher::AES.new(256, :CBC)
      aes.decrypt
      aes.key = key
      aes.iv = iv
      return {:Data => aes.update(data) + aes.final, :BetaProblems => false}
    else
      # Message didn't authenticate
      return {:Data => data, :BetaProblems => true}
    end
  end

  def self.create_new_onion(key,title,info,user)
    @e_title_hash = Onion.aes256_encrypt(key,(title.length > 0 ? title : ' '))
    @e_info_hash = Onion.aes256_encrypt(key,(info.length > 0 ? info : ' '))
    @new_onion = Onion.create(:HashedUser => user, :HashedTitle => @e_title_hash[:EncryptedData], :Title_Iv => @e_title_hash[:Iv], :Title_AuthTag => @e_title_hash[:AuthTag], :HashedInfo => @e_info_hash[:EncryptedData], :Info_Iv => @e_info_hash[:Iv], :Info_AuthTag => @e_info_hash[:AuthTag])
  end

  def edit_onion_with_new_data(key,new_title,new_info)
    @e_title_hash = Onion.aes256_encrypt(key,(new_title.length > 0 ? new_title : ' '))
    @e_info_hash = Onion.aes256_encrypt(key,(new_info.length > 0 ? new_info : ' '))
    self.HashedTitle = @e_title_hash[:EncryptedData]
    self.Title_Iv = @e_title_hash[:Iv]
    self.Title_AuthTag = @e_title_hash[:AuthTag]
    self.HashedInfo = @e_info_hash[:EncryptedData]
    self.Info_Iv = @e_info_hash[:Iv]
    self.Info_AuthTag = @e_info_hash[:AuthTag]
    self.save
  end

  def self.decrypted_onion(key,onion)
    hashedTitle = Onion.aes256_decrypt(key,Base64.decode64(onion.HashedTitle),Base64.decode64(onion.Title_Iv),Base64.decode64(onion.Title_AuthTag))
    hashedInfo = Onion.aes256_decrypt(key,Base64.decode64(onion.HashedInfo),Base64.decode64(onion.Info_Iv),Base64.decode64(onion.Info_AuthTag))
    onion.HashedTitle = hashedTitle[:Data]
    onion.HashedInfo = hashedInfo[:Data]
    betaProblems = hashedTitle[:BetaProblems] || hashedInfo[:BetaProblems]
    return {:BetaProblems => betaProblems}
  end

end
