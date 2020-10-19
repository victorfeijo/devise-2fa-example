class AddOtpEnabledAtToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :otp_enabled_at, :datetime
  end
end
