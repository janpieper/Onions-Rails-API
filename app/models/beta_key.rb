require 'securerandom'

class BetaKey < ActiveRecord::Base
  attr_accessible :Active, :Code

  def self.create_beta_keys(count)
    for i in 0..count.to_i
      BetaKey.create(:Code => SecureRandom.uuid, :Active => true)
    end
  end

  def self.beta_key_is_active(code)
    @keys = BetaKey.where(:Code => code, :Active => true)
    @keys.size > 0
  end

  def self.use_beta_key(code)
    @keys = BetaKey.where(:Code => code, :Active => true)
    @keys.each do |k|
      k.Active = false
      k.save
    end
  end

end
