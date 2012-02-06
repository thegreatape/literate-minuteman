require 'test_helper'

class MinutemanBotTest < ActiveSupport::TestCase
  test "creating a new instance" do
    assert SearchBots::MinutemanBot.new('209303')
  end
  
  test "looking up simple results via classic record page" do
    bot = SearchBots::MinutemanBot.new('209303')
    uri = "http://find.minlib.net/iii/encore/search/C%7CSGardens+of+the+Moon+Steven+Erikson%7COrightresult%7CU1?lang=eng&suite=pearl"
    response = Hashie::Mash.new({
      :body => fixture_file('search_bots/minuteman_bot/gardens_of_the_moon.html')
    })
    bot.stubs(:fetch).with(uri).returns(response)

    ['b2852617', 'b2347273', 'b2236667'].each do |id|
      record_response = Hashie::Mash.new({
        :body => fixture_file('search_bots/minuteman_bot/gardens_of_the_moon_records.html')
      })
      bot.stubs(:fetch).with("http://library.minlib.net/record=#{id}").returns(record_response)
    end

    results = bot.find("Gardens of the Moon", "Steven Erikson")
    assert_equal 4, results.length
    [["Cambridge", "Out"], 
     ["Needham", "In"], 
     ["Newton", "Out"], 
     ["Wellesley", "Out"]].each do |pair|
      assert results.any? {|i| i[:status] == pair[1] && i[:location] == pair[0]}
     end
    
  end
end
