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
  AREA_ID = 'JP26'.freeze
  def station
    self.raspio_station
  end
  concerning :TimeTable do
    extend ActiveSupport::Concern
    extend self
    def add(dates)
      dates.each do |date|
        date = Date.parse(date) if date.is_a?(String)
        add_time_table(date)
      end
    end

    private

    def add_time_table(date)
      uri = URI.parse("https://radiko.jp/v3/program/date/#{date.strftime('%Y%m%d')}/#{AREA_ID}.xml")
      xml = Net::HTTP.get(uri)
      doc = REXML::Document.new(xml)
      REXML::XPath.match(doc, 'radiko/stations/station').map do |station|
        station_id = station.attributes['id']
        date = Date.strptime(station.elements['progs/date'].text, '%Y%m%d')
        REXML::XPath.match(station, 'progs/prog').map do |program|
          id = program.attributes['id']
          ft = program.attributes['ft'] + '+09:00'
          from = Time.strptime(ft, '%Y%m%d%H%M%S%Z')
          to = Time.strptime(program.attributes['to'] + '+09:00', '%Y%m%d%H%M%S%Z')
          title = hankaku(program.elements['title'].text)
          description = descript(program)
          homepage = program.elements['url'].text
          prog = Raspio::Program.find_or_initialize_by(id:)
          d = date
          d -= 1 if late_time?(from)
          prog.update(raspio_station_id: station_id, title:, from:, to:, description:, homepage:, date: d)
          prog.save
        end
      rescue StandardError => e
        logger.error(e)
        raise ActiveRecord::Rollback
      end
    end

    def hankaku(text)
      NKF.nkf('-W -w -Z1', text).strip
    end

    def descript(program)
      concat = "#{program.elements['desc'].text}#{program.elements['info'].text}"
      stripped = ActionController::Base.helpers.strip_tags(concat).gsub(/&gt;|&lt/, "&gt;" => ">", "&lt;" => "<").gsub(/\t+|\n+/, "\n")

      hankaku(stripped)
    end

    def late_time?(time)
      num = time.strftime('%H%M').to_i
      [*0...459].include?(num)
    end
  end
end
