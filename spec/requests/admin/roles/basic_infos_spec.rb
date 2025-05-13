require 'rails_helper'

RSpec.describe "Admin::Roles::BasicInfosController", type: :request do
  let(:user_with_permission) { create(:user, permissions_list: [ 'edit_basic_info' ]) }
  let(:user_without_permission) { create(:user) }
  let!(:role) { create(:role) }

  def turbo_stream_action(response_body, action)
    doc = Nokogiri::HTML.fragment(response_body)
    doc.css("turbo-stream[action='#{action}']").first
  end

  def turbo_stream_target_id(turbo_stream_element)
    turbo_stream_element["target"]
  end

  describe "GET /admin/roles/:id/basic_info/edit" do
    context "when authenticated and user HAS :edit_basic_info permission for the role" do
      before { sign_in(user_with_permission, scope: :user) }

      it "responds with a turbo_stream to replace the role basic info content" do
        get edit_admin_role_basic_info_path(role)

        expect(response).to have_http_status(:success)
        expect(response.media_type).to eq Mime[:turbo_stream]

        stream_element = turbo_stream_action(response.body, "replace")
        expect(stream_element).not_to be_nil
        expect(turbo_stream_target_id(stream_element)).to eq "role_basic_info_content"
      end
    end

    context "when authenticated and user DOES NOT HAVE :edit_basic_info permission for the role" do
      before { sign_in(user_without_permission, scope: :user) }

      it "raises CanCan::AccessDenied" do
        expect {
          get edit_admin_role_basic_info_path(role)
        }.to raise_error(CanCan::AccessDenied)
      end
    end

    context "when not authenticated" do
      it "redirects to the sign-in page" do
        get edit_admin_role_basic_info_path(role)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when the role does not exist" do
      before { sign_in(user_with_permission, scope: :user) }

      it "responds with 404 Not Found" do
        get "/admin/roles/invalid-id/basic_info/edit"
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
