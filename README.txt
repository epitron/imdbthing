== MAKE IT GO ===================================

Install gems:
  $ gem install epitools
  $ gem install pry
  $ gem install mechanize -v 1.0
  $ gem install print_members

== USE IT =======================================

Run:
  $ ruby imdbthing.rb

  pry> ls
  pry> mgm.print
  pry> mgm.query { year == 1975 }.print
  pry> movies.histo { title =~ /Love/ }
