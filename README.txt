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

  # Show all commands:
  pry(#<Movies>)> ls
  
  # Show all movies released by Warner Brothers:
  pry(#<Movies>)> warner.print 
  
  # Show all movies released by MGM in 1975:
  pry(#<Movies>)> mgm.query { year == 1975 }.print 
  
  # Display a graph of movie release frequency (by year):
  pry(#<Movies>)> timeline 
  
  # Display a histogram of number of movies with "Love" in the title (per year)
  pry(#<Movies>)> movies.histo { title =~ /Love/ }  

If you want to add more movie studios, edit the COMPANIES
table at the top of imdbthing.rb, delete movies.dump,
then re-run the script. It'll automatically re-scrape all
the companies (the previously scraped ones will be cached).
