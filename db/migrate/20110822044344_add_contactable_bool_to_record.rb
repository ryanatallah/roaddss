class AddContactableBoolToRecord < ActiveRecord::Migration
  def self.up
    add_column :records, :contactable, :boolean
  end

  def self.down
    remove_column :records, :contactable
  end
end