class Borrowable < ApplicationRecord
  belongs_to :item_type
  has_many :copies, dependent: :destroy, counter_cache: true
  has_many :borrowings, through: :copies

  has_one :book, dependent: :destroy

  validates :title, presence: true
  validates :copies_count, numericality: { greater_than_or_equal_to: 0 }
  validates :type, presence: true

  def specific_data
    case type
    when "BookBorrowable"
      book
    when "MagazineBorrowable"
      magazine
    when "DvdBorrowable"
      dvd
    else
      nil
    end
  end

  def self.create_with_specific_data(type_class, borrowable_attrs, specific_attrs)
    transaction do
      borrowable = create!(borrowable_attrs.merge(type: "#{type_class}Borrowable"))
      specific = type_class.create!(specific_attrs.merge(borrowable: borrowable))
      borrowable
    end
  end
end
