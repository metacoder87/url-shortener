namespace :prune do
  desc "TODO"
  task old_urls: :environment do
    minutes = ENV['minutes'].to_i || 150
    puts "Auto pruning old URLs..."
    ShortenedUrl.prune(minutes)
  end
end
