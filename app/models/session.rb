require 'securerandom'

class Session < ActiveRecord::Base
  attr_accessible :HashedUser, :Key

  def self.new_session(user_hash)
  	session_key = SecureRandom.uuid
  	Session.where(:HashedUser => user_hash).destroy_all
  	s = Session.create(:HashedUser => user_hash, :Key => session_key.to_s)
    if s.id > 2000000000
      Session.reset_sessions
    end
  	return session_key.to_s
  end

  def self.user_hash_for_session(session_key)
  	@sessions = Session.where(:Key => session_key)
  	@session = @sessions[0]
    if @session
      if @session.created_at + 1.hours > Time.now
         return @session.HashedUser
      else
         @sessions.destroy_all
         return nil
      end
    end

    return nil
  end

  def self.reset_sessions
    s = Session.find_by_sql('ALTER SEQUENCE sessions_id_seq RESTART WITH 1')
  end

end
