class ShortenedUrl < ApplicationRecord
    validates :short_url, :long_url, :submitter, presence: true
    validates :short_url, uniqueness: true

    belongs_to :submitter,
        primary_key: :id,
        class_name: :User,
        foreign_key: :submitter_id

    def self.random_code
        loop do
            rando = SecureRandom.urlsafe_base64(16)
            return rando unless ShortenedUrl.exists?(short_url: rando)
        end
    end
end