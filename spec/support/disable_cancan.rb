RSpec.configure do |config|
  config.before(:each, type: :controller) do |example|
    unless example.metadata[:authorize]
      allow(controller).to receive(:authorize!).and_return(true)
    end
  end

  config.before(:each, type: :request) do |example|
    unless example.metadata[:authorize]
      allow_any_instance_of(ApplicationController)
        .to receive(:authorize!).and_return(true)
    end
  end
end
