class Admin::Roles::BasicInfosController < Admin::BaseController
  def edit
    @role = Role.find(params[:role_id])

    authorize! :edit_basic_info, @role

    render turbo_stream: turbo_stream.replace(
      "role_basic_info_content",
      partial: "admin/roles/form",
      locals: { role: @role }
    )
  end
end
