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
  def station
    self.raspio_station
  end

  def self.add(dates)
    dates.map! do |d|
      if d.is_a?(String)
        Date.parse(d).strftime('%Y%m%d')
      else
        d.strftime('%Y%m%d')
      end
    end
    dates.each do |d|
      add_programs(d)
    end
  end

  def self.add_datestr(dates_str)
    dates_str.each do |d_str|
      add_programs(d_str)
    end
  end

  def hankaku(text)
    NKF.nkf('-W -w -Z1', text).strip
  end

  def description(program)
    concat = "#{program.elements['desc'].text}#{program.elements['info'].text}"
    stripped = ActionController::Base.helpers.strip_tags(concat).gsub(/&gt;|&lt/, "&gt;" => ">", "&lt;" => "<").gsub(/\t+|\n+/, "\n")

    hankaku(stripped)
  end

  def late_time?(time)
    num = time.strftime('%H%M').to_i
    [*0...459].include?(num)
  end

  def self.add_programs(datestr)
    uri = URI.parse("https://radiko.jp/v3/program/date/#{datestr}/#{@@area_id}.xml")
    xml = Net::HTTP.get(uri)
    doc = REXML::Document.new(xml)
    REXML::XPath.match(doc, 'radiko/stations/station').map do |station|
      station_id = station.attributes['id']
      date = Date.strptime(station.elements['progs/date'].text, '%Y%m%d')
      REXML::XPath.match(station, 'progs/prog').map do |schedule|
        id = schedule.attributes['id']
        program = Raspio::Program.find_or_initialize_by(id:)
        ft = schedule.attributes['ft'] + '+09:00'
        from = Time.strptime(ft, '%Y%m%d%H%M%S%Z')
        to = Time.strptime(schedule.attributes['to'] + '+09:00', '%Y%m%d%H%M%S%Z')
        title = program.hankaku(schedule.elements['title'].text)
        description = program.description(schedule)
        homepage = schedule.elements['url'].text
        d = date
        d -= 1 if program.late_time?(from)
        program.update(raspio_station_id: station_id, title:, from:, to:, description:, homepage:, date: d)
        program.save
      end
    rescue StandardError => e
      # e.full_message do |message|
      Rails.logger.error(e.full_message)
      # end
      raise ActiveRecord::Rollback
    end
  end
end
