require 'rexml/document'
require 'net/http'
require 'nkf'
uri = URI.parse('https://radiko.jp/v3/station/list/JP26.xml')
xml = Net::HTTP.get(uri)
doc = REXML::Document.new(xml)
REXML::XPath.match(doc, '/stations/station').map do |station|
  tmp_name = station.elements['name'].text
  name = NKF.nkf('-W -w -Z1', tmp_name).strip
  id = station.elements['id'].text
  banner = station.elements['banner'].text || nil
  timeshift = station.elements['timefree'].text.to_i == 1

  station = Raspio::Station.find_or_initialize_by(id:)
  station.update(name:, banner:, timeshift:)
end
