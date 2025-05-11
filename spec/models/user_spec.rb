require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  describe "factory" do
    it "is valid" do
      expect(build_stubbed(:user)).to be_valid
    end
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
  end

  describe "associations" do
    it { is_expected.to have_many(:users_roles).dependent(:destroy) }
    it { is_expected.to have_many(:roles) }
  end

  describe "profile_image attachment" do
    subject(:persisted_user) { create(:user) }

    let(:valid_file)   { fixture_file_upload("spec/fixtures/files/pixel.png", "image/png") }
    let(:large_file)   { dummy_file(filename: "large.jpg",  type: "image/jpeg", content: "a" * 6.megabytes) }
    let(:text_file)    { dummy_file(filename: "test.txt",   type: "text/plain", content: "not an image") }
    let(:exe_file)     { dummy_file(filename: "test.exe",   type: "application/octet-stream", content: "binary_data") }

    it "uses the correct uploader class" do
      expect(User.new.profile_image_attacher.shrine_class).to eq(ImageUploader)
    end

    context "with a valid image" do
      before do
        persisted_user.profile_image = valid_file
        persisted_user.save!
        persisted_user.reload
      end

      it "attaches the file" do
        expect(persisted_user.profile_image).to be_a(ImageUploader::UploadedFile)
        expect(persisted_user.profile_image.original_filename).to eq("pixel.png")
        expect(persisted_user.profile_image.mime_type).to eq("image/png")
      end

      it "generates a thumbnail derivative" do
        derivatives = persisted_user.profile_image_derivatives

        expect(derivatives).to include(:thumbnail)
        thumb = derivatives[:thumbnail]

        expect(thumb).to be_a(ImageUploader::UploadedFile)
        expect(thumb.url).to be_present
      end
    end

    context "with invalid files" do
      it "rejects oversized files" do
        persisted_user.profile_image = large_file
        expect(persisted_user).not_to be_valid
        expect(persisted_user.errors[:profile_image])
          .to include(I18n.t('errors.image.file_size', max_size: ImageUploader::MAX_SIZE / 1024 / 1024))
      end

      it "rejects non-image mime types" do
        persisted_user.profile_image = text_file
        expect(persisted_user).not_to be_valid
        expect(persisted_user.errors[:profile_image])
          .to include(I18n.t('errors.image.mime_type', valid_types: ImageUploader::VALID_MIME_TYPES.join(', ')))
      end

      it "rejects disallowed extensions" do
        persisted_user.profile_image = exe_file
        expect(persisted_user).not_to be_valid
        expect(persisted_user.errors[:profile_image])
          .to include(I18n.t('errors.image.extension', valid_extensions: ImageUploader::VALID_EXTENSIONS.join(', ')))
      end
    end
  end
end
