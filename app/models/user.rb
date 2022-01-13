class User < ApplicationRecord
    validates :email, uniqueness: true, presence: true

    has_many :submitter_urls,
        primary_key: :id,
        class_name: :ShortenedUrl,
        foreign_key: :submitter_id
end