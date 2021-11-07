class AddStateToSettings < ActiveRecord::Migration
  def change
    add_column :mailchimp_settings, :state, :string, default: 'inactive'
  end
end
