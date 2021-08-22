class CreateInvoices < ActiveRecord::Migration[6.1]
  def change
    create_table :invoices do |t|
      t.string :title, null: false, default: ''
      t.string :filename, null: false, default: ''
      t.string :file_seq, null: false, default: ''

      t.timestamps
    end
  end
end
