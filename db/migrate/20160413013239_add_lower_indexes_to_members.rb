class AddLowerIndexesToMembers < ActiveRecord::Migration

  def up
  	execute %{
  		CREATE INDEX 
  			members_lower_last_name
  		ON
  			members (lower(last_name) varchar_pattern_ops)
  	}
  	execute %{
  		CREATE INDEX 
  			members_lower_first_name
  		ON
  		 	members (lower(first_name) varchar_pattern_ops)
  	}
  	execute %{
  		CREATE INDEX 
  			members_lower_email
  		ON
  			members (lower(email))
  	}
  end

  def down
  	remove_index :members, name: 'members_lower_last_name'
  	remove_index :members, name: 'members_lower_first_name'
  	remove_index :members, name: 'members_lower_email'
  end

end
