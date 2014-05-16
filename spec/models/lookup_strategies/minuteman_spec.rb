require 'spec_helper'

describe LookupStrategies::Minuteman do
  it "normalizes the location name" do
    {
      "BROOKLINE/COOLIDGE CORNER/Paperback" => "Brookline/Coolidge Corner",
      "SOMERVILLE/Young Adult" => "Somerville"

    }.each do |raw, expected|
      expect(LookupStrategies::Minuteman.normalize_location_name(raw)).to eq(expected)
    end
  end
end
