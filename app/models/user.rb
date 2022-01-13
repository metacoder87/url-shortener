class User < ApplicationRecord
    validates :email, uniqueness: true, presence: true

    has_many :submitted_urls,
        primary_key: :id,
        class_name: :ShortenedUrl,
        foreign_key: :submitter_id

    has_many :visits,
        primary_key: :id,
        class_name: :Visit,
        foreign_key: :user_id

    has_many :visited_urls,
        through: :visits,
        source: :shortened_url
end