FactoryGirl.define do
  factory :post do
    sender  { FactoryGirl.create(:user).actor }
    body   { |n| "post#{ n }" }
  end
end