require 'rest-client'
require 'json'
require 'pry'

def request_and_parse(url = 'http://www.swapi.co/api/people/')
  all_characters = RestClient.get(url)
  JSON.parse(all_characters)
end

def get_character_movies_from_api(character)
  #make the web request and find character's hash we've searched for
  character_data = get_character_hash(character) #returns character hash of the character we've searched for

  # iterate over the character hash to find the collection of `films` for the given
  #   `character`
  # collect those film API urls, make a web request to each URL to get the info
  #   for that film
  # return value of this method should be collection of info about each film.
  #   i.e. an array of hashes in which each hash reps a given film
  collect_film_info(character_data)
  # this collection will be the argument given to `parse_character_movies`
  #  and that method will do some nice presentation stuff: puts out a list
  #  of movies by title. play around with puts out other info about a given film.
end

def get_character_hash(character)
  character_hash = request_and_parse
  my_character_hash = nil
  while !my_character_hash do
    my_character_hash = character_hash["results"].find do |my_char_hash|
      my_char_hash["name"] == character
    end
    character_hash = request_and_parse(character_hash["next"])
  end
  my_character_hash
end

def collect_film_info(character_data)
  character_data["films"].map do |film_url|
    request_and_parse(film_url)
  end
end

def parse_character_movies(films_hash)
  # some iteration magic and puts out the movies in a nice list
  films_hash.each do |film|
    puts film["title"]
  end
end

def show_character_movies(character)
  films_hash = get_character_movies_from_api(character)
  parse_character_movies(films_hash)
end

## BONUS

# that `get_character_movies_from_api` method is probably pretty long. Does it do more than one job?
# can you split it up into helper methods?
