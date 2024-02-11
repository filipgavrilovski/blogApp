FactoryBot.define do
    factory :article do
      title { "Sample Article" }
      body { "This is a sample article body." }
      status { "public" }
    end
  end