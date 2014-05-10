require 'spec_helper'

describe CopySerializer do
  it "has the expected fields" do
    synced_at = 34.minutes.ago
    copy = create(
      :copy,
      title: 'Annihilation',
      author: 'Allen Steele',
      call_number: 'SF VanderMeer, Jeff',
      status: 'In',
      last_synced_at: synced_at,
      location: create(:location, name: 'SOMERVILLE/Adult')
    )

    json = CopySerializer.new(copy).as_json
    expect(json[:copy][:title]).to eq 'Annihilation'
    expect(json[:copy][:author]).to eq 'Allen Steele'
    expect(json[:copy][:call_number]).to eq 'SF VanderMeer, Jeff'
    expect(json[:copy][:status]).to eq 'In'
    expect(json[:copy][:last_synced_at]).to eq synced_at
    expect(json[:copy][:location_name]).to eq 'SOMERVILLE/Adult'
  end
end
