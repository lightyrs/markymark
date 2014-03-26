# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :link do
    title "MyString"
    description "MyText"
    url "MyString"
    image_url "MyString"
    content "MyText"
    domain "MyString"
    posted_at "2014-03-26 00:10:50"
  end
end
