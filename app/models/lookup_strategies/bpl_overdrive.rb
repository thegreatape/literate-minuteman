class LookupStrategies::BplOverdrive
  HOST = 'http://overdrive.bpl.org'

  attr_accessor :title, :author
  def initialize(title, author)
    self.title = title
    self.author = author
  end

  def find
    overdrive_strategy.find
  end

  private
  def overdrive_strategy
    @overdrive_strategy ||= LookupStrategies::Overdrive.new(HOST, "BPL Overdrive", title, author)
  end

end
