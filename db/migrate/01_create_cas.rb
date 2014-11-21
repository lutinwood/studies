class CreateCas < ActiveRecord::Migration
  def self.up
    create_table "cas", :force => true do |t|
      t.column "name", :string, :limit => 60, :default => "", :null => false
      t.column "identifier", :string, :limit => 20, :null => false
      t.column "url", :string, :limit => 60
      t.column "ldap", :string, :limit => 60
      t.column "dn", :string, :limit => 255
    end
  end

  def self.down
    drop_table :cas
  end

end
