class ShortenedUrl < ApplicationRecord
    validates :short_url, :long_url, :submitter, presence: true
    validates :short_url, uniqueness: true

    belongs_to :submitter,
        primary_key: :id,
        class_name: :User,
        foreign_key: :submitter_id

    has_many :visits,
        primary_key: :id,
        class_name: :Visit,
        foreign_key: :shortened_url_id

    has_many :visitors,
        Proc.new { distinct },
        through: :visits,
        source: :visitor

    def self.random_code
        loop do
            rando = SecureRandom.urlsafe_base64(16)
            return rando unless ShortenedUrl.exists?(short_url: rando)
        end
    end

    def self.create_shortened_url(user, long_url)
        ShortenedUrl.create!(
            short_url: ShortenedUrl.random_code,
            long_url: long_url,
            submitter_id: user.id
        )
    end

    def num_clicks
        visits.count
    end

    def num_uniques
        visits.select('user_id').distinct.count
    end

    def num_recent_uniques
        visits.select('user_id').where('created_at > ?', 10.minutes.ago).distinct.count
    end
end