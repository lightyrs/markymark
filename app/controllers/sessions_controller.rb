class SessionsController < ApplicationController

  after_action :after_login_flow, only: [:create]

  def new
    redirect_to "/auth/#{params[:provider]}"
  end

  def create
    auth = request.env['omniauth.auth']

    # Find an identity here
    @identity = Identity.find_with_omniauth(auth)

    if @identity.nil?
      # If no identity was found, create a brand new one here
      @identity = Identity.create_with_omniauth(auth)
    end

    if signed_in?
      if @identity.user == current_user
        # User is signed in so they are trying to link an identity with their
        # account. But we found the identity and the user associated with it
        # is the current user. So the identity is already associated with
        # this user. So let's display an error message.
        @identity.update_token(auth)
        redirect_to root_url, notice: "Already linked that account!"
      else
        # The identity is not associated with the current_user so lets
        # associate the identity
        @identity.user = current_user
        @identity.save
        HarvestLinksWorker.perform_async(@identity.user.id, @identity.provider_id)
        redirect_to root_url, notice: "Successfully linked that account!"
      end
    else
      if @identity.user.present?
        # The identity we found had a user associated with it so let's
        # just log them in here
        self.current_user = @identity.user
        @identity.update_token(auth)
        @just_logged_in = true
        redirect_to root_url, notice: "Logged in!"
      else
        # No user associated with the identity so we need to create a new one
        self.current_user = User.find_or_create_with_omniauth(@identity, auth)
        @just_logged_in = true
        redirect_to root_url, notice: "Logged in!"
      end
    end
  end

  def destroy
    self.current_user = nil
    redirect_to root_url, notice: 'Logged out!', anchor: 'logged_out'
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message].humanize}"
  end

  private

  def after_login_flow
    if @just_logged_in
      current_user.update_attributes(logged_in_at: Time.now)
      HarvestLinksWorker.perform_async(@identity.user.id, @identity.provider_id)
    end
  end
end
