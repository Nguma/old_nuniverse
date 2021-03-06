class AddConnections < ActiveRecord::Migration
  def self.up
		create_table :connections do |t|
			t.column	:subject_id, :integer
			t.column	:object_id, :integer
			t.column 	:public, :boolean, :default => true
      t.timestamps
	  end
		add_index :connections, [:subject_id, :object_id], :unique => true
		add_index	:connections, :subject_id
		add_index :connections, :object_id
		add_index :connections, :public
  end

  def self.down
		drop_table :connections
  end
end
