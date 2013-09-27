require 'bcrypt'

class AccountsController < ApplicationController
	respond_to :json, :html

	def index
		if session[:SessionKey]
      Session.where(:Key => session[:SessionKey]).destroy_all
			session[:SessionKey] = nil
		end
		if session[:UserKey]
			session[:UserKey] = nil
		end
	end

	def show
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end

	def create
		if params[:account]
			login = params[:account]
			if login[:User] && login[:Pass]
				# Params are GOOD
				encrypted_user = Account.hashed_user(login[:User])
				if (Account.account_exists(encrypted_user))
					# Account exists for that Email
					if (Account.pass_is_good(login[:Pass],encrypted_user))
						@users = Account.where(:HashedUser => encrypted_user)
						@user = @users[0]
						sKey = Session.new_session(encrypted_user)
						aesKey = Account.aes_key(login[:User],login[:Pass],@user.Salt)
						session[:SessionKey] = sKey
						session[:UserKey] = aesKey
						respond_with({:error => "Unauthorized Access"}.as_json, :location => "/onions")
					else
						# User&Pass Mismatch
						respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
					end
				else
					# User&Pass Mismatch
					respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
				end
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/?BadPassword=true")
		end
	end

	def delete_account
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	# Login 
	def login_api
    if params[:ApiKey] && ApiKey.is_api_key_active(params[:ApiKey])
      if params[:User] && params[:Pass]
        # Params are GOOD
        encrypted_user = Account.hashed_user(params[:User])
        if (Account.account_exists(encrypted_user))
          # Account exists for that Email
          if (Account.pass_is_good(params[:Pass],encrypted_user))
            salt = Account.where(:HashedUser => encrypted_user)[0].Salt
            sKey = Session.new_session(encrypted_user)
            respond_with({:SessionKey => sKey, :Salt => salt}.as_json, :location => nil)
          else
            respond_with({:error => "Email/Password Mismatch"}.as_json, :location => nil)
          end
        else
          respond_with({:error => "Email/Password Mismatch"}.as_json, :location => nil)
        end
      else
        respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
      end
    else
      respond_with({:error => "Invalid API Key"}.as_json, :location => nil)
    end
	end


	# NEW ACCOUNT API
	def new_account_api
    if params[:ApiKey] && ApiKey.is_api_key_active(params[:ApiKey])
      if params[:User] && params[:Pass]
        # No Account exists, make one
        encrypted_user = Account.hashed_user(params[:User])
        if Account.account_exists(encrypted_user)
          respond_with({:error => "Account already exists"}.as_json, :location => "/")
        else
          hashedPass = Account.new_hashed_pass(params[:Pass])
          salt = Account.generate_salt
          sKey = Session.new_session(encrypted_user)
          @account = Account.create(:HashedUser => encrypted_user, :HashedPass => hashedPass, :Salt => salt)
          respond_with({:SessionKey => sKey, :Salt => salt}.as_json, :location => "/")
        end
      else
        # Params are BAD
        respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
      end
    else
      respond_with({:error => "Invalid API Key"}.as_json, :location => nil)
    end
	end


	# NEW ACCOUNT WEB
	def new_account_web
		if params[:register]
			register = params[:register]
			if register[:User] && register[:Pass] && register[:BetaCode]
				if BetaKey.beta_key_is_active(register[:BetaCode])
          encrypted_user = Account.hashed_user(register[:User])
          if Account.account_exists(encrypted_user)
            respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new?AccountExists=true")
          else
            hashedPass = Account.new_hashed_pass(register[:Pass])
            salt = Account.generate_salt
            @account = Account.create(:HashedUser => encrypted_user, :HashedPass => hashedPass, :Salt => salt)
            session[:SessionKey] = Session.new_session(encrypted_user)
            session[:UserKey] = Account.aes_key(register[:User],register[:Pass],salt)
            BetaKey.use_beta_key(register[:BetaCode])
            respond_with({:error => "Unauthorized Access"}.as_json, :location => "/onions")
          end
        else
          respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new?BadBetaCode=true")
        end
			else
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new?BadParams=true")
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/new")
		end
	end


	# LOGOUT
	def logout_web
    Session.where(:Key => session[:SessionKey]).destroy_all
    session[:UserKey] = nil
		session[:SessionKey] = nil
		redirect_to("/")
  end


  # LOGOUT API
  def logout_api
    if params[:SessionKey] && params[:ApiKey] && ApiKey.is_api_key_active(params[:ApiKey])
      Session.where(:Key => params[:SessionKey]).destroy_all
      respond_with({:Status => "Success"}.as_json, :location => nil)
    else
      respond_with({:error => "Invalid API Key"}.as_json, :location => nil)
    end
  end

  def about
     #
  end


  # DELETE ACCOUNT
  def delete_account_web
    #
  end

  def delete_account_final
    if params[:account]
      login = params[:account]
      if login[:User] && login[:Pass]
        # Params are Good
        encrypted_user = Account.hashed_user(login[:User])
        if (Account.account_exists(encrypted_user))
          # Account exists for that Username
          if (Account.pass_is_good(login[:Pass],encrypted_user))
            Account.where(:HashedUser => encrypted_user).destroy_all
            Onion.where(:HashedUser => encrypted_user).destroy_all
            Session.where(:HashedUser => encrypted_user).destroy_all
            redirect_to('/?Deleted=true')
          else
            # User&Pass Mismatch
            respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
          end
        else
          # User&Pass Mismatch
          respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
        end
      end
    else
      respond_with({:error => "Unauthorized Access"}.as_json, :location => "/deleteAccount?BadPassword=true")
    end
  end

  def delete_account_api
    if params[:SessionKey] && params[:ApiKey] && ApiKey.is_api_key_active(params[:ApiKey])
      if params[:User] && params[:Pass]
        # Params are Good
        encrypted_user = Account.hashed_user(params[:User])
        if Account.account_exists(encrypted_user)
          # Account exists for that Username
          if (Account.pass_is_good(params[:Pass],encrypted_user))
            Account.where(:HashedUser => encrypted_user).destroy_all
            Onion.where(:HashedUser => encrypted_user).destroy_all
            Session.where(:HashedUser => encrypted_user).destroy_all
            respond_with({:Status => "Success"}.as_json, :location => nil)
          else
            respond_with({:error => "User/Password Mismatch"}.as_json, :location => nil)
          end
        else
          respond_with({:error => "User/Password Mismatch"}.as_json, :location => nil)
        end
      else
        respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
      end
    else
      respond_with({:error => "Invalid API Key"}.as_json, :location => nil)
    end
  end


  def donate
    @total_accounts = Account.count
    @total_onions = Onion.count
  end


end
