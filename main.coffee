class Movies
  constructor: (filename = 'data/ml-data/u.item') ->
    fs = require 'fs'
    readFile = (input) -> fs.readFileSync input, 'utf-8'
    file = readFile filename
    @movies = {}
    lines = file.split('\n')
    for line in lines
      unless line is ''
        data = line.split('|')
        id = data[0]
        name = data[1]
        @movies[id] = name

  getMovies: -> @movies
  getMovieName: (i) -> @movies[i]
  getNumMovies: -> Object.keys(@movies).length

class Ratings
  constructor: (filename = 'data/ml-data/u.data') ->
    fs = require 'fs'
    readFile = (input) -> fs.readFileSync input, 'utf-8'
    file = readFile filename
    @ratings = {}
    @averageRating = {}
    lines = file.split('\n')
    for line in lines
      unless line is ''
        data = line.split('\t')
        idUser = data[0]
        idMovie = data[1]
        rating = (Number) data[2]
        if @ratings[idUser] is undefined
          @ratings[idUser] = {}
        @ratings[idUser][idMovie] = rating
        if @averageRating[idUser] is undefined
          @averageRating[idUser] = rating
        else
          @averageRating[idUser] += rating
    for k of @averageRating
      @averageRating[k] /= Object.keys(@ratings[k]).length

  getRatings: -> @ratings
  getAverageRating: -> @averageRating

class Recommender
  constructor: (@ratings, @avgRatings, @myRatings) ->
    @myAvgRating = 0.0
    for k, v of @myRatings
      @myAvgRating += (Number) v
    @myAvgRating /= Object.keys(@myRatings).length

  getNeighbourhoods: (num) ->
    @neighbourhoods = {}
    for user of @ratings
      matches = []
      for movie of @myRatings
        if @ratings[user][movie] != undefined
          matches.push movie
      if matches.length > 0
        num = 0.0
        userDen = 0.0
        otherUserDen = 0.0
        for movie in matches
          u = @myRatings[movie] - @myAvgRating
          v = @ratings[user][movie] - @avgRatings[user]
          num += u * v
          userDen += u * u
          otherUserDen += v * v
        if userDen is 0 or otherUserDen is 0
          matchRate = 0
        else
          matchRate = num / (Math.sqrt(userDen) * Math.sqrt(otherUserDen))
      else
        matchRate = 0
      @neighbourhoods[user] = matchRate

getRandomInt = (min, max) -> Math.floor(do Math.random * max) + min
getRandomMovie = (numMovies) -> getRandomInt(1, numMovies)
getRandomRating = -> getRandomInt(1, 5)

NUM_RATINGS = 20
NUM_NEIGHBOURHOODS = 10
NUM_RECOMMENDATIONS = 20

# import database
mlMovies = new Movies
mlRatings = new Ratings

# get my ratings
myRatings = {}
numMovies = do mlMovies.getNumMovies
n = 0
while n < NUM_RATINGS
  idMovie = getRandomMovie numMovies
  while myRatings[idMovie] != undefined
    idMovie = getRandomMovie numMovies
  rating = do getRandomRating
  myRatings[idMovie] = rating
  n++

recommender = new Recommender mlRatings.getRatings(), mlRatings.getAverageRating(), myRatings
recommender.getNeighbourhoods(NUM_NEIGHBOURHOODS)
