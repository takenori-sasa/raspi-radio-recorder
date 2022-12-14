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
  REXML::XPath.match(station, 'progs/prog').map do |program|
    ft = program.attributes['ft'] + '+09:00'
    from = Time.strptime(ft, '%Y%m%d%H%M%S%Z')
    to = Time.strptime(program.attributes['to'] + '+09:00', '%Y%m%d%H%M%S%Z')
    title = hankaku(program.elements['title'].text)
    description = desc(program)
    homepage = program.elements['url'].text
    Raspio::Program.create(station_id:, title:, from:, to:, description:, homepage:)
  end
end
