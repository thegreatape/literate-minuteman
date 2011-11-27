class AddMinutemanLibrarySystem < ActiveRecord::Migration
  def up
    LibrarySystem.create!(:search_bot_class => "SearchBots::MinutemanBot",
                          :name => "Massachusetts Minuteman Library Network")
  end

  def down
    LibrarySystem.find_by_name( "Massachusetts Minuteman Library Network" ).destroy
  end
end
