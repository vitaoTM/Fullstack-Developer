class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy, :toggle_role ]

  def index
    @users = policy_scope(User)
  end

  def show
    authorize @user
  end

  def new
    @user = User.new
    authorize @user
  end

  def create
    @user = User.new
    authorize @user

    if @user.save
      redirect_to admin_user_path(@user), notice: "User created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @user
  end

  def update
    authorize @user
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted"
  end

  def toggle_role
    authorize @user, :toggle_role?

    if @user.admin?
      @user.user!
    else
    @user.admin!
    end
  end


  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:full_name, :email, :password, :password_confirmations, :role, :avatar_image, :avatar_url)
  end
end
