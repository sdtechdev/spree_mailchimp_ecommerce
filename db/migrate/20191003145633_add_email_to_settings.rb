class AddEmailToSettings < ActiveRecord::Migration
  def change
    add_column :mailchimp_settings, :mailchimp_store_email, :string
  end
end
