class AddPremiumToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column(:users, :premium, :boolean, {null: false})
  end
end
