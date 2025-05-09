module FileHelpers
    def dummy_file(filename: "pixel.png", type: "image/png", content: nil)
        if content
        file = Tempfile.new(filename)
        file.binmode
        file.write(content)
        file.rewind
        ActionDispatch::Http::UploadedFile.new(
            tempfile: file,
            filename: filename,
            type: type
        )
        else
        fixture_file_upload(Rails.root.join("spec/fixtures/files", filename), type)
        end
    end
end

RSpec.configure do |config|
    config.include FileHelpers
end
