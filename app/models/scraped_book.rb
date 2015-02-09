class ScrapedBook
  ATTRIBUTES = [:title, :location, :call_number, :status, :url]
  attr_accessor *ATTRIBUTES

  def initialize(options={})
    options.each do |k,v|
      self.public_send("#{k}=", v)
    end
  end
end
