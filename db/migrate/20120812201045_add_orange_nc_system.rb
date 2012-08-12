class AddOrangeNcSystem < ActiveRecord::Migration
  def up
    execute("""
    INSERT INTO library_systems (search_bot_class, name, created_at, updated_at) VALUES 
      ('SearchBots::OrangeNCBot', 'Orange County North Carolina Public Library', NOW(), NOW())
    """)
  end

  def down
    execute("""
    DELETE FROM library_systems 
    WHERE search_bot_class = 'SearchBots::OrangeNCBot' 
    """)
  end
end
