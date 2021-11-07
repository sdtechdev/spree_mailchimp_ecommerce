class AddAccountNameToMailchimpSetting < ActiveRecord::Migration
  def change
    add_column :mailchimp_settings, :mailchimp_account_name, :string
  end
end
