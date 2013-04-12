== SET IT UP ========================================

Install gems:
  $ gem install epitools
  $ gem install pry
  $ gem install mechanize -v 1.0

Or:
  $ bundle

== MAKE IT GO =======================================

Run:
  $ ruby imdbthing.rb

  [ it'll scrape all the movies from IMDB on the first run
    and save them to "movies.dump" ]

  pry(#<Movies>)> ls
  pry(#<Movies>)> warner.print
  pry(#<Movies>)> mgm.query { year == 1975 }.print
  pry(#<Movies>)> timeline
  pry(#<Movies>)> movies.histo { title =~ /Love/ }

If you want to add more movie studios, edit the COMPANIES
table at the top of imdbthing.rb, delete movies.dump,
then re-run the script. It'll automatically re-scrape all
the companies (the previously scraped ones will be cached).