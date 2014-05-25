class LookupStrategies::Boston
  include LookupStrategies::Browser
  HOST = 'http://bpl.bibliocommons.com'

  attr_accessor :title, :author
  def initialize(title, author)
    self.title = title
    self.author = author
  end

  def find
    session.visit search_url

    copies = []
    location_buttons.each do |location_button|

      result_title = extract_title(location_button)
      location_button.click

      session.within location_modal do
        location_rows.each do |row|
          copies << copy_data(row, result_title)
        end

        modal_close_button.click
      end
    end

    copies
  end

  private

  def extract_title(location_button)
    location_button.find(:xpath, '../..').find('.title').text
  end

  def copy_data(row, result_title)
    cells = row.all('td')
    ScrapedBook.new(title: result_title,
                    location: normalize_location(cells[0].text),
                    call_number: "#{cells[1].text} #{cells[2].text}",
                    status: cells[3].text)
  end

  def modal_close_button
    session.find('a.close')
  end

  def location_buttons
    session.all('.availability a.circInfo')
  end

  def location_modal
    ".modal-box"
  end

  def location_rows
    session.all("#circulation_details table tbody tr:not(.note)")
  end

  def search_url
    "#{HOST}/search?t=smart&search_category=keyword&q=#{query}&commit=Search"
  end

  def query
    [title, author].map do |s|
      URI::escape(s.gsub(/\s/, '+'))
    end.join('+')
  end

  def normalize_location(name)
    # remove book count from location name
    name.gsub(/\s*\(\d+\)\s*/, '')
  end
end
