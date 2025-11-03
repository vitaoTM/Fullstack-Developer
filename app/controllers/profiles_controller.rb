class ProfilesController < ApplicationController
  before_action :set_user_profile

  def show
    authorize @user_profile
  end

  def edit
    authorize @user_profile
  end

  def update
    authorize @user_profile
    if @user_profile.update(profile_params)
      redirect_to profile_path, notice: "Profile updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user_profile
    @user_profile.destroy
    redirect_to root_path, notice: "Your account has been deleted."
  end

  private

  def set_user_profile
    @user_profile = current_user
  end

  def profile_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmation, :avatar_image, :avatar_url)
  end
end
