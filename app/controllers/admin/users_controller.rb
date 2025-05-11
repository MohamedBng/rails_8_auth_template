class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :destroy, :edit, :update, :show ]
  load_and_authorize_resource class: "User"

  def index
    @q = User.ransack(params[:q])
    @users = @q.result(distinct: true).includes(:roles).page(params[:page]).per(10)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    uploaded_io = params[:user].delete(:profile_image)
    @user = User.new(new_user_params)

    set_random_password(@user)
    @user.skip_confirmation!

    if @user.save
      assign_profile_image(@user, uploaded_io) if uploaded_io
      @user.send_reset_password_instructions
      flash[:success] = t("admin.users.create.success")
      redirect_to admin_user_path(@user)
    else
      flash.now[:error] = @user.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render turbo_stream: turbo_stream.replace(
      "personal_info_user_#{@user.id}",
      partial: "admin/users/personal_info/form",
      locals: { user: @user }
    )
  end

  def update
    if @user.update(user_params)
      flash.now[:success] = t("admin.users.update.success")
      redirect_to admin_user_path(@user)
    else
      flash.now[:error] = t("admin.users.update.failure", errors: @user.errors.full_messages.join(", "))
      render turbo_stream: turbo_stream.replace(
        "personal_info_user_#{@user.id}",
        partial: "admin/users/personal_info/form",
        locals: { user: @user }
      ), status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy

    if @user.errors.any?
      flash[:error] = t("admin.users.destroy.failure", errors: @user.errors.full_messages.join(", "))
      redirect_to admin_user_path(@user)
      return
    end

    flash[:success] = t("admin.users.destroy.success")

    redirect_to admin_users_path
  end

  def delete_profile_image
    @user.remove_profile_image = true

    if @user.save
      flash.now[:success] = t("admin.users.delete_profile_image.success")
      redirect_to admin_user_path(@user)
    else
      flash.now[:error] = t("admin.users.delete_profile_image.failure", errors: @user.errors.full_messages.join(", "))
      render turbo_stream: turbo_stream.replace(
        "personal_info_user_#{@user.id}",
        partial: "admin/users/personal_info/form",
        locals: { user: @user }
      ), status: :unprocessable_entity
    end
  end

  private

  def set_random_password(user)
    random_password = Devise.friendly_token.first(20)
    user.password = user.password_confirmation = random_password
  end

  def assign_profile_image(user, uploaded_io)
    File.open(uploaded_io.tempfile.path, "rb") do |file|
      user.profile_image_attacher.assign(
        file,
        metadata: {
          filename:     uploaded_io.original_filename,
          content_type: uploaded_io.content_type
        }
      )
      user.save!
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :profile_image)
  end

  def new_user_params
    params.require(:user)
          .permit(:first_name, :last_name, :email, role_ids: [])
  end
end
