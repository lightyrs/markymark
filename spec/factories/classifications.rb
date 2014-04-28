# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :classification do
    name "MyString"
    content_type "MyString"
    description "MyText"
  end
end
