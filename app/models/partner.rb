class Partner < ApplicationRecord
  belongs_to :assessment, optional: true
  validates :date_of_birth, comparison: { less_than_or_equal_to: Date.current }
end
