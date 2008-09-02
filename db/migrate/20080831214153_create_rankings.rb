class CreateRankings < ActiveRecord::Migration
  def self.up
    create_table :rankings do |t|
			t.integer	:tagging_id, :null => :no
			t.integer :user_id, :null => :no
			t.integer	:value, :default => 1
      t.timestamps
    end
		add_index :rankings, [:tagging_id, :user_id], :unique => true
  end

  def self.down
    drop_table :rankings
  end
end
