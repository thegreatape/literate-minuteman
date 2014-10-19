require 'uri'

class LookupStrategies::Overdrive
  include LookupStrategies::Browser

  attr_accessor :host, :title, :author, :location_title
  def initialize(host, location_title, title, author)
    self.title = title.gsub(/\([^)]+\)/, '')
    self.location_title = location_title
    self.author = author
    self.host = host
  end

  def find
    session.visit host
    search_for_book
    copies_from_links
  end

  private

  def copies_from_links
    # there's some JS going on with each click, so we can't just get all the urls
    # and open them serialially
    [].tap do |copies|
      (0..result_links.length-1).each do |i|
        result_links[i].click

        copies << extract_copy

        session.go_back
      end
    end
  end

  def extract_copy
    ScrapedBook.new(title: copy_title,
                    location: location_title,
                    call_number: "",
                    url: session.current_url,
                    status: copy_status)
  end

  def copy_title
    session.find("#detailsTitle h3").text
  end

  def copy_status
    session.all('#copiesExpand .row').map do |row|
      row.all('.columns').map(&:text).join(' ')
    end.join(" / ")
  end

  def search_for_book
    session.fill_in "FullTextCriteria", with: "#{title} #{author}"
    session.find("input[title='Submit search']").click
  end

  def result_links
    session.all('li.title-element-li a.tc-title')
  end

end
