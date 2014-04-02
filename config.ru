require 'excon'
require 'builder'
require 'json'

def rss(messages)
  xml = Builder::XmlMarkup.new
  xml.instruct! :xml, :version => '1.1', :encoding => 'UTF-8'
  xml.rss version: "2.0" do
    xml.channel do
      xml.title "Github Status"
      xml.language "en-us"

      messages.each do |message|
        xml.item do
          xml.title message["status"]
          xml.description message["body"]
          xml.pubDate Time.parse(message["created_on"]).rfc822
        end
      end
    end
  end
end

GITHUB_STATUS_URI = ENV['GITHUB_STATUS_URI'] || 'https://status.github.com/api/messages.json'

run lambda { |env|
  messages = JSON.parse(Excon.get(GITHUB_STATUS_URI, idempotent: true, expects: 200).body)
  [200, {"Content-Type" => "application/xml;charset=utf-8"}, [rss(messages)]]
}
