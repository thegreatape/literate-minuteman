require 'test_helper'

class MinutemanBotTest < ActiveSupport::TestCase
  test "creating a new instance" do
    assert SearchBots::MinutemanBot.new('209303', 'key')
  end
  
  test "looking up simple results without ajax" do
    bot = SearchBots::MinutemanBot.new('209303', 'key')
    uri = "http://find.minlib.net/iii/encore/search/C%7CSGardens+of+the+Moon+Steven+Erikson%7COrightresult%7CU1?lang=eng&suite=pearl"
    response = Hashie::Mash.new({
      :body => fixture_file('search_bots/minuteman_bot/gardens_of_the_moon.html')
    })
    bot.stubs(:fetch).with(uri).returns(response)

    results = bot.find("Gardens of the Moon", "Steven Erikson")
    assert_equal 8, results.length
    [["Available","Waltham"],
     ["Available","Natick"],
     ["Available","Wellesley"],
     ["Available","Wellesley"],
     ["Out","Cambridge"],
     ["In","Needham"],
     ["Out","Newton"],
     ["In","Wellesley"]].each do |pair|
      assert results.any? {|i| i[:status] == pair[0] && i[:location] == pair[1]}
     end
    
  end
end
