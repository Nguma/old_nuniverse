class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
			t.integer :tagging_id
			t.integer :user_id
			t.string	:role, :default => "viewer"
      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end
