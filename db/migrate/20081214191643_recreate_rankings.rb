class RecreateRankings < ActiveRecord::Migration
    def self.up
			drop_table :rankings
      create_table :rankings do |t|
        t.column :rankable_id, :integer
				t.column :rankable_type, :string
				t.column :user_id, :integer
				t.column :score, :float, :default => 0
				t.timestamps
      end
    end

    def self.down
      # drop_table :rankings
    end
  end

