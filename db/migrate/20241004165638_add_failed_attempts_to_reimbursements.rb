class AddFailedAttemptsToReimbursements < ActiveRecord::Migration[7.1]
  def change
    add_column :reimbursements, :failed_attempts, :integer
  end
end
