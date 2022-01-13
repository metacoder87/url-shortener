class Visit < ApplicationRecord
    validates :visitor, :shortened_url, presence: true

    belongs_to :visitor,
        primary_key: :id,
        class_name: :User,
        foreign_key: :user_id

    belongs_to :shortened_url

end