class CreateMembers < ActiveRecord::Migration
  def change
    create_table :members do |t|
      t.string :first_name,  null: false
      t.string :last_name,   null: false
      t.string :email,       null: false
      t.string :username,    null: false
      t.timestamps           null: false
    end

    add_index :members, :email,    unique: true
    add_index :members, :username, unique: true
  end
end
