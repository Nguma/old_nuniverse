class AddPolymorphicParentToFact < ActiveRecord::Migration
  def self.up
		add_column :facts, :parent_id, :integer
		add_column :facts, :parent_type, :string
		add_index :facts, [:parent_id, :parent_type], :name => :parent
  end

  def self.down
		remove_index :facts, :parent
		remove_column :facts, :parent_id
		remove_column :facts, :parent_type
  end
end
