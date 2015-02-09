require 'spec_helper'

describe LookupStrategies::Minuteman do
  it "normalizes the location name" do
    {
      "BROOKLINE/COOLIDGE CORNER/Paperback" => "Brookline/Coolidge Corner",
      "SOMERVILLE/Young Adult" => "Somerville",
      "Belmont" => "Belmont"

    }.each do |raw, expected|
      expect(LookupStrategies::Minuteman.new('title', 'author').normalize_location_name(raw)).to eq(expected)
    end
  end
end
