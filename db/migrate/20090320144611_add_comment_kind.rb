class AddCommentKind < ActiveRecord::Migration
  def self.up
		add_column :comments, :kind, :string, :default => "Comment"
		
		add_index :comments, :kind
  end

  def self.down
		remove_index :comments, :kind
		remove_column :comments, :kind
  end
end
