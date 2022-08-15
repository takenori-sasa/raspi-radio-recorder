# nethttp2.rb
require 'rexml/document'
require 'net/http'
require 'nkf'
def hankaku(text)
  NKF.nkf('-W -w -Z1', text).strip
end

def desc(program)
  concat = program.elements['desc'].text + program.elements['info'].text
  stripped = ActionController::Base.helpers.strip_tags(concat.gsub(/(<BR>)+/, "\r\n").gsub(/^\r\n/, ''))
  hankaku(stripped)
end
uri = URI.parse('https://radiko.jp/v3/program/date/20220814/JP26.xml')
xml = Net::HTTP.get(uri)
doc = REXML::Document.new(xml)
REXML::XPath.match(doc, 'radiko/stations/station').map do |station|
  station_id = station.elements['id'].text
  # date = station.elements['progs/date'].text
  REXML::XPath.match(station, 'progs/prog').map do |program|
    from = program.attributes['ft']
    to = program.attributes['to']
    title = hankaku(program.elements['title'].text)
    description = desc(program)
    url = program.elements['url'].text
    Raspio::TimeTable.create(station_id:, title:, from:, to:, description:, url:)
  end
end
