== MAKE IT GO ===================================

Install gems:
  $ gem install epitools
  $ gem install pry
  $ gem install mechanize -v 1.0

Or:
  $ bundle

== USE IT =======================================

Run:
  $ ruby imdbthing.rb

  pry(#<Movies>)> ls
  pry(#<Movies>)> warner.print
  pry(#<Movies>)> mgm.query { year == 1975 }.print
  pry(#<Movies>)> timeline
  pry(#<Movies>)> movies.histo { title =~ /Love/ }
