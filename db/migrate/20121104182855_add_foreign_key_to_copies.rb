class AddForeignKeyToCopies < ActiveRecord::Migration
  def up
    execute <<-SQL
    delete from copies where copies.id in (
      select copies.id from copies
      left join books on copies.book_id = books.id
      where books.id is null )
    SQL

    execute <<-SQL
      alter table copies
      add constraint fk_copies_books
      foreign key (book_id)
      references books (id)
    SQL
  end

  def down 

    execute <<-SQL
      alter table copies
      drop constraint fk_copies_books
      SQL
  end
end
