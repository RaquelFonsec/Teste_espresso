
FactoryBot.define do
    factory :reimbursement do
      company
      client
      payable
      value { 100.0 }
      description { "Reimbursement for services" }
      due_date { Date.tomorrow }
      payment_method { "credit_card" }
      cost { 50.0 }
      status { "pendente" }
    end
  end
  
