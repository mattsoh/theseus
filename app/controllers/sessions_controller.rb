class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:omniauth_failure, :hackclub_callback]

  skip_after_action :verify_authorized

  def impersonate
    unless current_user.admin?
      redirect_to root_path, alert: "you are not authorized to impersonate users. this incident has been reported :-P"
      Honeybadger.notify("Impersonation attempt by #{current_user.username} to #{params[:id]}")
      return
    end

    session[:impersonator_user_id] ||= current_user.id
    user = User.find(params[:id])
    session[:user_id] = user.id
    flash[:success] = "hey #{user.username}! how's it going? nice 'stache and glasses!"
    redirect_to root_path
  end

  def stop_impersonating
    session[:user_id] = session[:impersonator_user_id]
    session[:impersonator_user_id] = nil
    redirect_to root_path, notice: "welcome back, 007!"
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "bye, see you next time!"
  end

  def omniauth_failure
    redirect_to login_path, alert: "Authentication failed: #{params[:message]}"
  end

  def hackclub_callback
    auth = request.env["omniauth.auth"]

    if auth.nil?
      redirect_to login_path, alert: "Authentication failed"
      return
    end

    begin
      @user = User.from_hack_club_auth(auth)
    rescue => e
      Rails.logger.error "Error creating user from Hack Club Auth: #{e.message}"
      uuid = Honeybadger.notify(e)
      redirect_to login_path, alert: "error authenticating! (error: #{uuid})"
      return
    end

    if @user&.persisted?
      session[:user_id] = @user.id
      flash[:success] = "welcome aboard!"
      redirect_to root_path
    else
      Rails.logger.error "Failed to create/update user from Hack Club Auth"
      redirect_to login_path, alert: "are you sure you should be here?"
    end
  end
end
