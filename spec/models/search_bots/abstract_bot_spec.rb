require 'spec_helper'

describe SearchBots::AbstractBot do
  before do
    @user = Factory(:user)
    @bot = SearchBots::AbstractBot.new(@user.goodreads_id)
  end

  after do
    Goodreads::Client.any_instance.unstub(:shelf)
  end

  it "using default shelf" do
    expect_shelves 'to-read'
    @bot.lookup
  end

  it "using active shelf" do
    @user.active_shelves = ['wishlist']
    @user.save

    expect_shelves 'wishlist'
    @bot.lookup
  end

  it "using multiple active shelves" do
    @user.active_shelves = ['photography', 'wishlist']
    @user.save

    expect_shelves 'photography', 'wishlist'
    @bot.lookup
  end

  def expect_shelves(*args)
    args.each do |shelf|
      Goodreads::Client.any_instance.expects(:shelf).with(@user.goodreads_id, shelf, per_page: 100).returns(Hashie::Mash.new({books: []}))
    end
  end

end


