class SessionsController < ApplicationController
	respond_to :json

	def index
    respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end

	def show
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end

	def create
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
	end

	def delete
		respond_with({:error => "Unauthorized Access"}.as_json, :location => nil)
  end
	
end
