require 'rubygems'
require 'json'

def scan(re)
  JSON.load(IO.read('cache.json')).map { |record|
    match = false
    record['results'].each do |subentry|
      subentry['locations'].each do |k,v|
        match ||= (v == "Available" and k == "Cambridge")
      end
    end
    "#{record['title']} / #{record['author']}" if match 
  }.reject(&:nil?)
end

ARGV.each do |branch|
  puts "Matching your to-read list against library branch #{branch}" 
  results = scan(Regexp.new(branch))
  puts "Found #{results.length} matches available now.\n---"
  results.each {|i| puts i }
end
