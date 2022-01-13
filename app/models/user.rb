class User < ApplicationRecord
    validates :email, uniqueness: true, presence: true

    has_many :submitted_urls,
        primary_key: :id,
        class_name: :ShortenedUrl,
        foreign_key: :submitter_id
end