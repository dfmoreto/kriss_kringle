FactoryBot.define do
 factory :member do
   name         { FFaker::Lorem.word }
   email        { FFaker::Internet.email }
   token        { SecureRandom.urlsafe_base64(nil, false) }
   campaign
 end
end
