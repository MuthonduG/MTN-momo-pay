class CreateMomopays < ActiveRecord::Migration[7.0]
  def change
    create_table :momopays do |t|
      t.string :amount
      t.string :phone_number
      t.string :merchantRequestID
      t.string :checkoutRequestID
      t.string :momoReceiptNumber

      t.timestamps
    end
  end
end
