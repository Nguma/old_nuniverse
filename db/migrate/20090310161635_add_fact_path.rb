class AddFactPath < ActiveRecord::Migration
  def self.up
		add_column :facts, :path, :string
		add_index :facts, :path
		
		Fact.find(:all).each do |f|
			f.path = "/#{f.parent.unique_name}/#{f.unique_name}"
			f.save
		end
  end

  def self.down
		remove_column :facts, :path
  end
end
