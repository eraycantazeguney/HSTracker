#!/usr/bin/env ruby

deployment_target ||= '10.8'

hstracker_zip = './sparkle/release/HSTracker.zip'
hstracker_dsym_zip = './hstracker.dsym.zip'
`rm -f #{hstracker_zip}`
`rm -f #{hstracker_dsym_zip}`

version = nil
changelog = []

File.open './versions.markdown', 'r' do |file|
  started = false
  file.each_line do |line|
    if line =~ /^####\s/
      if started
        break
      else
        version = line.gsub(/(#|\s)/, '')
        puts "new #{version}"
        started = true
        next
      end
    else
      changelog << line.strip
    end
  end
end

if changelog.empty? || version.nil?
  puts "Can't find new version"
  exit(1)
end

require 'redcarpet'
puts 'Generating versions'
content = File.read('./versions.markdown')
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
html = markdown.render(content)
File.open('./sparkle/config/release_notes.content.html', 'w') { |file| file.write(html) }

puts 'Packing release'
`rake sparkle:package mode=release`

puts 'Zipping dSYM'
`zip -r #{hstracker_dsym_zip} build/MacOSX-#{deployment_target}-Release/HSTracker.app.dSYM`

puts 'Uploading to HockeyApp'
`curl \
  -F "status=1" \
  -F "notify=0" \
  -F "notes=#{changelog.reject(&:empty?).join(" \\ \n")}" \
  -F "notes_type=1" \
  -F "ipa=@#{hstracker_zip}" \
  -F "dsym=@#{hstracker_dsym_zip}" \
  -H "X-HockeyAppToken: #{ENV['HOCKEY_API_TOKEN']}" \
  https://rink.hockeyapp.net/api/2/apps/#{ENV['HOCKEY_APP']}/app_versions/upload`
