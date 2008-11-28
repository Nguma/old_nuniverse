class CreateAudio < ActiveRecord::Migration
	def self.up
	      create_table :audios do |t|
	        t.column :parent_id,  :integer
	        t.column :content_type, :string
	        t.column :filename, :string
	        t.column :size, :integer
	      end
	    end

	    def self.down
	      drop_table :audios
	    end

end
