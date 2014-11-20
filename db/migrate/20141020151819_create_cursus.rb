class CreateCursus < ActiveRecord::Migration
  def self.up
    create_table :cursus do |t|
      t.column :ldap_id, :string
      t.column :group_name, :string
    end
  end

  def self.down
    drop_table :cursus
  end
end
