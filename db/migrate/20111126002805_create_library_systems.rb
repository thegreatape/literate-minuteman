class CreateLibrarySystems < ActiveRecord::Migration
  def change
    create_table :library_systems do |t|
      t.string :search_bot_class
      t.string :name

      t.timestamps
    end

    create_table :library_systems_users do |t|
      t.integer :library_system_id
      t.integer :user_id
    end

  end
end
