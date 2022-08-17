require 'rexml/document'
require 'net/http'
require 'nkf'
class Raspio::Program < ApplicationRecord
  belongs_to :raspio_station, class_name: 'Raspio::Station'
  validates :title, presence: true
  validates :date, presence: true
  validates :from, presence: true, comparison: { less_than: :to }
  validates :homepage, format: /\A#{URI::DEFAULT_PARSER.make_regexp(['http', 'https'])}\z/, allow_blank: true
  validates :to, presence: true, comparison: { greater_than: :from }
  @@area_id = 'JP26'
  # クラスメソッド(Raspio::Program.hogeたち)
  class << self
    def add(date)
      datestr = if date.is_a?(String)
                  Date.parse(date).strftime('%Y%m%d')
                else
                  date.strftime("%Y%m%d")
                end
      add_daily(datestr)
    end

    def add_daily(datestr)
      # return if self.date_cache?(datestr)

      xml = cache_xml(datestr)
      doc = REXML::Document.new(xml)
      all_valid = true
      REXML::XPath.match(doc, 'radiko/stations/station').map do |station|
        station_id = station.attributes['id']
        REXML::XPath.match(station, 'progs/prog').map do |schedule|
          to = Time.strptime(schedule.attributes['to'] + '+09:00', '%Y%m%d%H%M%S%Z')
          from = Time.strptime(schedule.attributes['ft'] + '+09:00', '%Y%m%d%H%M%S%Z')
          program = Raspio::Program.find_or_initialize_by(raspio_station_id: station_id, from:, to:)
          program.raspio_station_id = station_id
          program.set_from_schedule(schedule)
          all_valid &= program.save
        end
      end
      all_valid
    end

    def date_cache?(date)
      Rails.cache.exist?(cache_key(date))
    end

    private

    def cache_xml(datestr)
      uri = URI.parse("https://radiko.jp/v3/program/date/#{datestr}/#{@@area_id}.xml")
      Rails.cache.fetch(cache_key(datestr), expires_in: 1.day) do
        Net::HTTP.get(uri)
      end
    end

    def cache_key(date)
      datestr = if date.is_a?(String)
                  Date.parse(date).strftime('%Y%m%d')
                else
                  date.strftime("%Y%m%d")
                end
      "cache_programs_#{datestr}"
    end
  end
  # インスタンスメソッド(Raspio::Program.new.hogeたち)
  def station
    self.raspio_station
  end

  def set_from_schedule(schedule)
    ft = schedule.attributes['ft'] + '+09:00'
    self.from = Time.strptime(ft, '%Y%m%d%H%M%S%Z')
    self.to = Time.strptime(schedule.attributes['to'] + '+09:00', '%Y%m%d%H%M%S%Z')
    self.title = hankaku(schedule.elements['title'].text)
    self.description = descript(schedule)
    self.date = self.from.to_date
    self.date -= 1 if midnight_start?
    self.homepage = schedule.elements['url'].text
  end

  private

  def hankaku(text)
    NKF.nkf('-W -w -Z1', text).strip
  end

  def descript(schedule)
    concat = "#{schedule.elements['desc'].text}#{schedule.elements['info'].text}"
    stripped = ActionController::Base.helpers.strip_tags(concat).gsub(/&gt;|&lt/, "&gt;" => ">", "&lt;" => "<").gsub(/\t+|\n+/, "\n")

    hankaku(stripped)
  end

  def midnight_start?
    num = self.from.strftime('%H%M').to_i
    [*0...500].include?(num)
  end
end
