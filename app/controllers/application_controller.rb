# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def current_user
    session[:current_user]
  end

  def authenticated?(params)
    user = User.find( :first, :conditions => ["institution_id=? AND service_level_id=? AND segment_id=?", 
                                      params[:institution_id], params[:service_level_id],params[:segment_id]])
    if user && user.password.nil? && !params[:password].empty?
      user.password = params[:password]
      user.save!
      reset_session
      session[:current_user] = user
    else
      user && user.password == params[:password] && session[:current_user] = user
    end
  end

end
