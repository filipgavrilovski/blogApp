require 'rails_helper'

RSpec.describe Visible do
  # Dummy class including the Visible concern for testing
  class DummyClass
    include ActiveModel::Model
    include Visible

    attr_accessor :status

    def initialize(status)
      @status = status
    end
  end

  describe 'validations' do
    it 'validates status inclusion' do
      expect(DummyClass.new('public')).to be_valid
      expect(DummyClass.new('private')).to be_valid
      expect(DummyClass.new('archived')).to be_valid
      expect(DummyClass.new('invalid_status')).not_to be_valid
    end
  end

  describe 'class methods' do
    describe '.public_count' do
      it 'returns the count of articles with status public' do
        create_list(:article, 3, status: 'public')
        create_list(:article, 2, status: 'private')

        expect(Article.public_count).to eq(3)
      end
    end
  end

  describe 'instance methods' do
    describe '#archived?' do
      it 'returns true if status is archived' do
        dummy_class = DummyClass.new('archived')
        expect(dummy_class.archived?).to eq(true)
      end

      it 'returns false if status is not archived' do
        dummy_class = DummyClass.new('public')
        expect(dummy_class.archived?).to eq(false)
      end
    end
  end
end