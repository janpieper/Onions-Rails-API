require 'openssl'

class ApiKey < ActiveRecord::Base
  attr_accessible :Active, :Code, :Email

  def self.new_api_key(email)
    new_key = OpenSSL::Digest::SHA256.new(email + ENV['AUTH_TAG']).hexdigest
    ApiKey.create(:Active => true, :Code => new_key, :Email => email)
  end

  def self.is_api_key_active(code)
    @keys = ApiKey.where(:Code => code, :Active => true)
    @keys.size > 0
  end

  def self.lock_api_key_for_email(email)
    @keys = ApiKey.where(:Email => email)
    if @keys.size > 0
      key = @keys[0]
      key.Active = false
      key.save
    end
  end

  def self.unlock_api_key_for_email(email)
    @keys = ApiKey.where(:Email => email)
    if @keys.size > 0
      key = @keys[0]
      key.Active = true
      key.save
    end
  end

end
