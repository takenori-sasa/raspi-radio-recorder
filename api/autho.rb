# nethttp2.rb
require 'uri'
require 'net/http'
require 'base64'
require 'tempfile'

def partialKey(key, length, offset)
  Base64.encode64(key.slice(offset, length))
end

uri = URI.parse('https://radiko.jp/v2/api/auth1')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme === "https"

headers = { 'X-Radiko-App': 'pc_html5',
            'X-Radiko-App-Version': '0.0.1',
            'X-Radiko-User': 'dummy_user',
            'X-Radiko-Device': 'pc' }
res = http.get(uri.path, headers)
auth_token = res['X-Radiko-AuthToken']
key_length = res['X-Radiko-KeyLength'].to_i
key_offset = res['X-Radiko-KeyOffset'].to_i
AUTHKEY = 'bcd151073c03b352e1ef2fd66c32209da9ca0afa'.freeze
headers = { 'X-Radiko-AuthToken': auth_token,
            'X-Radiko-PartialKey': partialKey(AUTHKEY, key_length, key_offset),
            'X-Radiko-User': 'dummy_user',
            'X-Radiko-Device': 'pc' }
uri = URI.parse('https://radiko.jp/v2/api/auth2')
http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = uri.scheme == "https"
res = http.get(uri.path, headers)
# puts res.code
station_id = 'MBS'
from = '202208140300'
to = '202208140330'
output = 'output'
tmpfile = Tempfile.open(['tempaudio', ".aac"])
puts tmpfile.size
tmpfile.binmode
result = system("ffmpeg -headers \"X-Radiko-AuthToken:#{auth_token}\" -i \"https://radiko.jp/v2/api/ts/playlist.m3u8?station_id=#{station_id}&l=15&ft=#{from}00&to=#{to}00\" -y -loglevel \"error\" -acodec copy #{tmpfile.path}")
puts tmpfile.size
tmpfile.close
