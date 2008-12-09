class MakeConnectionsPolymorphic < ActiveRecord::Migration
  def self.up
		add_column :connections, :subject_type, :string
		add_column :connections, :object_type, :string
		# remove_index :connections, [:subject_id, :object_id]
		
		connections = Connection.find(:all)
		connections.each do |connection|
			
			subject_id = connection.subject.taggable_id rescue nil
			object_id = connection.object.taggable_id rescue nil
			
			if connection.subject_type.nil? && !subject_id.nil? && !object_id.nil?
				connection.subject_type = connection.subject.taggable_type
				connection.subject_id = subject_id
				connection.object_type = connection.object.taggable_type
				connection.object_id = object_id
				connection.save	
			end
		end		
		
		
		
		add_index :connections, [:subject_id, :subject_type]
		add_index :connections, [:object_id, :object_type]
		add_index :connections, [:subject_id, :subject_type, :object_id, :object_type], :unique => true, :name => "main"
		
  end

  def self.down
	
		remove_index :connections, [:subject_id, :subject_type, :object_id, :object_type], :unique => true
				
		Connection.find(:all).each do |connection|
			
			connection.subject_id = Tag.find(:first, :conditions => ['taggable_type = ? AND taggable_id = ?', connection.subject_type, connection.subject_id]).id
			connection.object_id =  Tag.find(:first, :conditions => ['taggable_type = ? AND taggable_id = ?', connection.subject_type, connection.subject_id]).id
			connection.save	
		end

		remove_index :connections, [:subject_id, :subject_type]
		remove_index :connections, [:object_id, :object_type]
		remove_column :connections, :subject_type, :string
		remove_column :connections, :object_type, :string
		

		add_index :connections [:subject_id, :object_id], :unique => true
  end
end
