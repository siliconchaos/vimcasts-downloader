#!/usr/bin/env ruby
require 'rss'

# requires axel (http://wilmer.gaa.st/main.php/axel.html) to be installed
# for osx use homebrew (http://mxcl.github.com/homebrew/) to install
# sudo brew install axel

unless ENV['PATH'].split(":").any? {|f| File.exists?("#{f}/axel")}
  puts "axel not in path. Please install axel or correct path if installed."
  exit
end

puts "\nDownloading rss index"
puts "======================================================================="

rss_string = open('http://vimcasts.org/feeds/quicktime').read
rss = RSS::Parser.parse(rss_string, false)
videos_urls = rss.items.map { |it| it.enclosure.url unless it.enclosure.nil? }.reverse.compact

#remove "?referrer=rss" from url
videos_urls = videos_urls.map { |url| url.split('?').first }

videos_filenames = videos_urls.map {|url| url.split('/').last }
incomplete_filenames = Dir.glob('*.m4v.st').collect{|f| f.sub(/.st$/, '')}
existing_filenames = Dir.glob('*.m4v') - incomplete_filenames
missing_filenames = videos_filenames - existing_filenames

puts "\nResuming #{incomplete_filenames.size} inclompletd videos"
puts "-----------------------------------------------------------------------"
incomplete_videos_urls = videos_urls.select { |video_url| incomplete_filenames.any? { |filename| video_url.match filename } }

incomplete_videos_urls.each do |video_url|
  filename = video_url.split('/').last
  puts "- #{filename}"
  %x(axel -q #{video_url}?referrer=rss )
end

puts "\nDownloading #{missing_filenames.size} missing videos"
puts "-----------------------------------------------------------------------"
missing_videos_urls = videos_urls.select { |video_url| missing_filenames.any? { |filename| video_url.match filename } }

missing_videos_urls.each do |video_url|
  filename = video_url.split('/').last
  puts "- #{filename}"
  %x(axel -q #{video_url}?referrer=rss )
end
puts "\n======================================================================="
puts 'Finished synchronization'