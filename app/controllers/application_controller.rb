class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :signed_in?

  private

  def current_user
    begin
      @current_user ||= User.find(session[:user_id]) if session[:user_id]
    rescue Exception => e
      nil
    end
  end

  def signed_in?
    return true if current_user
  end

  def current_user=(user)
    @current_user = user
    session[:user_id] = user.nil? ? user : user.id
  end
end
