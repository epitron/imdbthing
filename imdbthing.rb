#!/usr/bin/env ruby
require 'epitools'
require 'pry'
require 'curses'

class String
  def slug; downcase.gsub(/\s+/, "_"); end
end

class Array
  def print
    each(&:print)
    nil
  end

  def query(&block)
    select{ |e| e.instance_eval &block }.sort.uniq.reverse
  end

  def histo(output=nil, colorize=false, &block)
    block         = proc{ year }  unless block_given?
    output        = STDOUT        unless output != nil

    grouped       = uniq.group_by{ |e| e.instance_eval &block }
    grouped.delete(nil)
    grouped       = grouped.map_keys(&:to_s)

    biggest       = grouped.values.map(&:size).max
    biggest_key   = grouped.keys.map(&:size).max
    scale         = 1.0
    width         = Curses.cols.to_f - biggest_key - 2
    scale         = width / biggest if biggest > width

    if colorize
      colors = Hash[ grouped.values.flatten.map(&:company).uniq.sort.zip( (1..15).cycle ) ]
    end

    grouped.sort.each do |k,vs|
      if colorize
        company_counts = vs.group_by(&:company).sort_by { |company, movies| company }
        v = company_counts.map do |company, movies|
          pounds = (movies.size*scale).round
          color = colors[company]
          "<#{color}>#{"#" * pounds}</#{color}>"
        end.join.colorize
      else
      	if v
          pounds = (v.size*scale).round
        else
          pounds = 0
        end
        v = "#" * pounds
      end

      k = k.rjust biggest_key

      output.puts "#{k} #{v}" if output
    end

    if colorize
      output.puts "------------------------".grey
      output.puts "        legend:".light_blue
      output.puts "------------------------".grey
      output.puts
      output.puts colors.map{ |k,color| "<#{color}>#{k}</#{color}>" }.join('<7>, </7>').colorize
    end
  end

  alias_method :histogram, :histo

end

class Movie < Struct.new(:title, :year, :url, :company, :role)

  include Comparable

  def <=>(other)
    [year, title] <=> [other.year, other.title]
  end

  def eql?(other)
    [year, title] == [other.year, other.title]
  end

  alias_method :equal?, :eql?

  def hash
    [year, title].hash
  end

  def to_hash
    {
      :title=>title,
      :year=>year,
      :url=>url,
      :company=>company,
      :role=>role.to_s,
    }
  end

  def inspect
    "#\{#{title} (#{year}) [#{company}]}"
  end

  def print
    puts "<grey>(<white>#{year}<grey>) <light_cyan>#{title} <grey>[<light_purple>#{company}<grey>] - <light_blue>#{url}".colorize
  end

end

module QueryMe
  def query(&block)
    select(&block).sort.uniq.reverse
  end
end

class Object
  def mixin(mod)
    metaclass.instance_eval do
      include mod
    end
    self
  end
end


class Movies

  attr_accessor :movies


  @@db = Path["movies.dump"]

  @@companies = {
    "Film District" => "http://www.imdb.com/company/co0314851/",
    "Universal"     => "http://www.imdb.com/company/co0005073/",
    "Paramount"     => "http://www.imdb.com/company/co0023400/",
    "Touchstone"    => "http://www.imdb.com/company/co0049348/",
    "TriStar"       => "http://www.imdb.com/company/co0005883/",
    "Working Title" => "http://www.imdb.com/company/co0057311/",
    "MGM"           => "http://www.imdb.com/company/co0016037/",
    "Warner"        => "http://www.imdb.com/company/co0026840/",
    "Columbia"      => "http://www.imdb.com/company/co0050868/",
    "Fox"           => "http://www.imdb.com/company/co0000756/",
    "THINKfilm"     => "http://www.imdb.com/company/co0209877/",
    "Sony"          => "http://www.imdb.com/company/co0137851/",
    "DreamWorks"    => "http://www.imdb.com/company/co0040938/",
    "Happy Madison" => "http://www.imdb.com/company/co0059609/",
    "Mandate"       => "http://www.imdb.com/company/co0142446/",
    "Fox Searchlight"   => "http://www.imdb.com/company/co0028932/",
    "Paramount Vantage" => "http://www.imdb.com/company/co0179341/",
  }

  @@rolemap = {"Distributor" => :dist, "Production" => :prod}

  @@companies.keys.each do |key|
    define_method(key.slug) do
      query {|m| m.company == key }
    end
  end

  def initialize
    if @@db.exists?
      load!
    else
      scrape!
    end

    puts
  end

  def save!
    print "* Saving #{movies.size} movies to #{@@db.filename}: "
    time { @@db.write Marshal.dump(movies) }
  end

  def load!
    print "* Loading #{@@db.filename}:"
    time { self.movies = Marshal.load(@@db.read) }
    puts "  |_ #{movies.size} movies"
  end

  def scrape!
    b = Browser.new

    self.movies = @@companies.map do |company, url|

      puts "== #{company} ========================================="
      page = b.get(url)

      page.search("td ol li").map do |e|

        if e.text =~ /^(.+) \((\d+)\) \.\.\.\s+(Distributor|Production)/
          url = e.at("a")["href"]
          url = "http://www.imdb.com#{url}" if url
          Movie.new(title=$1, year=$2.to_i, url, company, role=@@rolemap[$3])
        end

      end.compact

    end.flatten

    save!
  end

  def to_db!
    require 'sequel'
    db = Sequel.connect "mysql://root@localhost/imdb"

    db.create_table :movies do
      primary_key :id
      # Struct.new(:title, :year, :url, :company, :role)
      String :title
      Integer :year
      String :url
      String :company
      String :role

      index :title
      index :year
      index :company
    end

    ms = db[:movies]

    movies.each do |m|
      ms.insert(m.to_hash)
      print "."
    end

    puts "Inserted #{ms.count} items"
  end

  def query(&block)
    movies.query(&block)
  end

  def histo(output=nil, &block)
    movies.histo(output, &block)
  end

  def timeline
    movies.histo(nil, true)
  end

end

#query { |m| m.year.in? 1980..1981}

Movies.new.pry
