require 'rest-client'
require 'json'
require 'pry'
require_relative "../lib/command_line_interface.rb"

#returns a nested hash from the website api. If no website provided, the default is /people page 1.
def request_and_parse(url = 'http://www.swapi.co/api/people/')
  all_characters = RestClient.get(url)
  JSON.parse(all_characters)
end

#takes a character name and finds and returns the hash for that character from the api
def get_character_hash(character)
  character_hash = request_and_parse
  my_character_hash = nil
  while !my_character_hash do
    my_character_hash = character_hash["results"].find do |my_char_hash|
      my_char_hash["name"].downcase == character
    end
    #if the character name does not show up on the current page, check the next pages.
    #if the character name does not appear on any pages (there is no "next"), report the issue.
    if my_character_hash == nil
      unless (character_hash["next"]==nil)
        character_hash = request_and_parse(character_hash["next"])
      else
        puts "Sorry, there is no character #{character}."
        return {}
      end
    end
  end
  my_character_hash
end

#takes a hash of a specific character's data and returns an array of hashes
#each hash contains data for a film
def collect_film_info(character_data)
    character_data["films"].map do |film_url|
      request_and_parse(film_url)
    end
end

#if character is not found in any of the pages, request a new character from user
#use the new name they input to find the hash of that character, and return it
def get_new_character
  character = get_character_from_user
  get_character_hash(character)
end

#takes a character name and searches for it in the Star Wars api
#within the character's hash, find the films they appear in
#use the film api's to make an array of film hashes, and return this array
def get_character_movies_from_api(character)
  #find character's hash we've searched for
  character_data = get_character_hash(character)
  #if character is not found in any of the pages, request a new character from user
  while character_data == {}
    character_data = get_new_character
  end
  # iterate over the character hash to find the collection of `films` for the given
  #   `character`
  # collect those film API urls, make a web request to each URL to get the info
  #   for that film, and put the hasehs of film info into an array.
  collect_film_info(character_data)
end

#takes an array of film hashes and puts out the titles from the nested film data.
def parse_character_movies(films_hash)
  # some iteration magic and puts out the movies in a nice list
  films_hash.each do |film|
    puts film["title"]
  end
end

#connects the get_character_movies_from_api and parse_character_movies methods
def show_character_movies(character)
  #obtains an array of film hashes from get_character_movies_from_api
  films_hash = get_character_movies_from_api(character)
  #and then puts that array of film hashes into parse_character_movies
  parse_character_movies(films_hash)
end

## BONUS

# that `get_character_movies_from_api` method is probably pretty long. Does it do more than one job?
# can you split it up into helper methods?
