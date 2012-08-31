require 'test_helper'

class MinutemanBotTest < ActiveSupport::TestCase
  test "creating a new instance" do
    assert SearchBots::MinutemanBot.new('209303')
  end
  
  test "looking up simple results without ajax" do
    bot = SearchBots::MinutemanBot.new('209303')
    uri = "http://find.minlib.net/iii/encore/search/C__SGardens+of+the+Moon+Steven+Erikson__Ff%3Afacetmediatype%3Aa%3Aa%3ABOOK%3A%3A__Orightresult__U1?lang=eng&suite=cobalt"
    response = Hashie::Mash.new({
      :body => fixture_file('search_bots/minuteman_bot/gardens_of_the_moon.html')
    })
    bot.stubs(:fetch).with(uri).returns(response)

    results = bot.find("Gardens of the Moon", "Steven Erikson")
    assert_equal 7, results.length
    [["In","Waltham"],
     ["In","Natick"],
     ["Out","Cambridge"],
     ["In","Needham"],
     ["Out","Newton"],
     ["In","Wellesley"]].each do |pair|
      assert results.any? {|i| i[:status] == pair[0] && i[:location] == pair[1]}
     end
     assert results.all? {|r| r[:call_number]}
    
  end
end
