class OnionsController < ApplicationController
	require 'base64'
	respond_to :json, :html

	def index
		@onions = nil
		if session[:SessionKey] && session[:UserKey]
			user_hash = Session.user_hash_for_session(session[:SessionKey])
			if user_hash
				@onions = Onion.where(:HashedUser => Session.user_hash_for_session(session[:SessionKey])).order("id")
        @onionhash = Onion.decrypted_onions_with_key(@onions,session[:UserKey])
				@onions = @onionhash[:Onions]
        @beta_problems = @onionhash[:BetaProblems]
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
			else
				redirect_to("/")
			end
		else
			redirect_to("/")
		end
  end


	def show
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	def create
		if params[:onion] && session[:SessionKey] && session[:UserKey]
			onion = params[:onion]
			@user_hash = Session.user_hash_for_session(session[:SessionKey])
			if @user_hash
        onionTitle = onion[:Title]
        onionInfo = onion[:Info]
				if params[:Id]
					# Edit Onion
					@edit_onion = Onion.find(params[:Id])
          @edit_onion.edit_onion_with_new_data(session[:UserKey], (onionTitle.length>75 ? onionTitle[0..74] : onionTitle), (onionInfo.length>800 ? onionInfo[0..799] : onionInfo)) if @edit_onion.HashedUser == @user_hash
        else
          # New Onion
					@new_onion = Onion.create_new_onion(session[:UserKey], (onionTitle.length>75 ? onionTitle[0..74] : onionTitle), (onionInfo.length>800 ? onionInfo[0..799] : onionInfo), @user_hash)
				end
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/onions")
				session[:SessionKey] = Session.new_session(@user_hash)
			else
				respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
			end
		else
			respond_with({:error => "Unauthorized Access"}.as_json, :location => "/")
		end
	end


	def delete
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end


	def get_all_onions
		if params[:SessionKey]
			@user_hash = Session.user_hash_for_session(params[:SessionKey])
			if @user_hash
				@onions = Onion.where(:HashedUser => @user_hash)
				respond_with({:Onions => @onions, :SessionKey => Session.new_session(@user_hash)}.as_json, :location => nil)
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def add_onion
		if params[:SessionKey]
			@user_hash = Session.user_hash_for_session(params[:SessionKey])
			if @user_hash
				@onion = Onion.create(:HashedUser => @user_hash, :HashedTitle => params[:HashedTitle], :HashedInfo => params[:HashedInfo])
				respond_with({:NewOnion => @onion, :SessionKey => Session.new_session(@user_hash)}.as_json, :location => nil)
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def edit_onion
		if params[:SessionKey]
			@user_hash = Session.user_hash_for_session(params[:SessionKey])
			if @user_hash
				@onion = Onion.find(params[:Id])
        if @onion.HashedUser == @user_hash
          @onion.HashedTitle = params[:HashedTitle]
          @onion.HashedInfo = params[:HashedInfo]
          if @onion.save
            respond_with({:Status => "Success", :SessionKey => Session.new_session(@user_hash)}.as_json, :location => nil)
          else
            respond_with({:error => "Onion failed to Save."}.as_json, :location => nil)
          end
        else
          respond_with({:error => "No User for Session"}.as_json, :location => nil)
        end
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def deleteOnion
		if params[:SessionKey]
			@user_hash = Session.user_hash_for_session(params[:SessionKey])
			if @user_hash
				@onion = Onion.find(params[:Id])
        if @onion.HashedUser == @user_hash
          @onion.destroy
          respond_with({:Status => "Success", :SessionKey => Session.new_session(@user_hash)}.as_json, :location => nil)
        else
          respond_with({:error => "No User for Session"}.as_json, :location => nil)
        end
			else
				respond_with({:error => "No User for Session"}.as_json, :location => nil)
			end
		else
			respond_with({:error => "No Session Key"}.as_json, :location => nil)
		end
	end


	def delete_onion_web
		if session[:SessionKey]
			userHash = Session.user_hash_for_session(session[:SessionKey])
			if userHash && params[:OnionId]
				@onion = Onion.find(params[:OnionId])
				if @onion.HashedUser == userHash
					@onion.destroy
					session[:SessionKey] = Session.new_session(userHash)
					redirect_to("/onions")
				else
					# No Permission
				end
			else
        # No Permission
			end
		else
      # No Permission
		end
	end

end
