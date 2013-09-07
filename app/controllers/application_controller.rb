class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_domain

  def check_domain
  	if Rails.env.production? and request.host.downcase != 'www.onions.io'
    	redirect_to request.protocol + 'onions.io' + request.fullpath, :status => 301
  	end
  end

end
