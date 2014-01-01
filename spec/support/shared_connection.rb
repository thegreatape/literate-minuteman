class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end

module SharedConnection
  def self.share!
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  end
end

RSpec.configure do |config|
  config.before do
    if example.metadata[:js]
      SharedConnection.share!
    end
  end
end
