# == Schema Information
#
# Table name: shortened_urls
#
#  id           :bigint           not null, primary key
#  long_url     :string           not null
#  short_url    :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  submitter_id :integer          not null
#
# Indexes
#
#  index_shortened_urls_on_short_url     (short_url) UNIQUE
#  index_shortened_urls_on_submitter_id  (submitter_id)
#
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
        foreign_key: :shortened_url_id,
        dependent: :destroy

    has_many :visitors,
        -> { distinct },
        through: :visits,
        source: :visitor

    has_many :taggings,
        primary_key: :id,
        foreign_key: :shortened_url_id,
        class_name: :Tagging,
        dependent: :destroy
    
    has_many :tag_topics,
        through: :taggings,
        source: :tag_topic

    def self.prune(n)
       ShortenedUrl
        .joins(:submitter)
        .joins('LEFT JOIN visits ON visits.shortened_url_id = shortened_urls.id')
        .where("(shortened_urls.id IN (
            SELECT shortened_urls.id
            FROM shortened_urls
            JOIN visits
            ON visits.shortened_url_id = shortened_urls.id
            GROUP BY shortened_urls.id
            HAVING MAX(visits.created_at) < \ '#{n.minute.ago}\'
        ) OR (
            visits.id IS NULL and shortened_urls.created_at < \'#{n.minute.ago}\'
        )) AND users.premium = \'f\'")
        .destroy_all 
    end

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
        visitors.count
    end

    def num_recent_uniques
        visits.select('user_id').where('created_at > ?', 10.minutes.ago).distinct.count
    end

    private

    def no_spamming
        prev_minute = ShortenedUrl
            .where('created_at >= ?', 1.minute.ago)
            .where(submitter_id: submitter_id).length

        errors[:maximum] << 'limit reached on short urls' if prev_minute >= 5
    end

    def nonpremium_max
        return if User.find(self.submitter_id).premium 
        
        number_of_urls = ShortenedUrl
            .where(submitter_id: submitter_id).length

        errors[:Only] << 'premo members can generate more than five.' if number_of_urls >= 5
    end

end
