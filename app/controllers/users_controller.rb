class UsersController < ApplicationController

  def edit
    @user = User.find(params[:id])
    redirect_to root_path unless @user == current_user
  end

  def update
    @user = User.find(params[:id])

    redirect_to root_path unless @user == current_user

    if @user.update_attributes(secure_params)
      redirect_to @user
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])
    redirect_to root_path unless @user == current_user
  end

  private

  def secure_params
    params.require(:user).permit(:email)
  end
end
