class Book < Borrowable
  validates :isbn, presence: true
  validates :author, :genre, presence: true

  scope :filter_by, ->(filters = {}) {
    return all if filters.blank?

    permitted = filters.respond_to?(:permit) ?
                  filters.permit(:title, :author, :genre).to_h :
                  filters.to_h.slice(:title, :author, :genre)
    permitted = permitted.compact_blank
    return all if permitted.blank?

    conditions = permitted.transform_values { |value| "%#{value}%" }
    where(conditions.map { |key, value| "#{key} ILIKE ?" }.join(" AND "), *conditions.values)
  }
end
