class BetaKeysController < ApplicationController
  respond_to :json, :html

  def index
    if params[:pass] == ENV['DEV_API_KEY']
      if params[:create]
        BetaKey.create_beta_keys(params[:create])
      end
      @keys = BetaKey.where(:Active => true)
      respond_with({:keys => @keys}.as_json)
    else
      respond_with({:error => 'Unauthorized Access'}.as_json)
    end
  end

  def show
    respond_with({:error => 'Unauthorized Access'}.as_json)
  end

  def create
    respond_with({:error => 'Unauthorized Access'}.as_json)
  end

  def delete
    respond_with({:error => 'Unauthorized Access'}.as_json)
  end

end
