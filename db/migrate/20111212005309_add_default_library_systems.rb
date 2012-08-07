class AddDefaultLibrarySystems < ActiveRecord::Migration
  def up
    execute("""
    INSERT INTO library_systems (search_bot_class, name, created_at, updated_at) VALUES 
      ('SearchBots::MinutemanBot', 'Massachusetts Minuteman Library Network', NOW(), NOW()),
      ('SearchBots::BplBot',       'Boston Public Library System', NOW(), NOW())
    """)
  end

  def down
    execute("""
    DELETE FROM library_systems 
    WHERE search_bot_class = 'SearchBots::MinutemanBot' 
        OR search_bot_class = 'SearchBots::BplBot'
    """)
  end
end
