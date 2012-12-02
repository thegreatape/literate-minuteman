class ChangeCopyVarcharsToText < ActiveRecord::Migration
  def change
    change_column :copies, :title, :text
    change_column :copies, :author, :text
  end
end
