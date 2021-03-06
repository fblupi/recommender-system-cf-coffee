# Read and store database of movies
class Movies
  constructor: (filename = 'data/ml-data/u.item') ->
    fs = require 'fs'
    readFile = (input) -> fs.readFileSync input, 'utf-8'
    file = readFile filename
    @movies = {}
    lines = file.split '\n'
    for line in lines
      unless line is ''
        data = line.split '|'
        id = data[0]
        name = data[1]
        @movies[id] = name

  getMovies: -> @movies
  getMovieName: (i) -> @movies[i]
  getNumMovies: -> Object.keys(@movies).length

#############################################################################################################################

# Read and store ratings of movies
class Ratings
  constructor: (filename = 'data/ml-data/u.data') ->
    fs = require 'fs'
    readFile = (input) -> fs.readFileSync input, 'utf-8'
    file = readFile filename
    @ratings = {}
    @averageRating = {}
    lines = file.split '\n'
    for line in lines
      unless line is ''
        data = line.split '\t'
        idUser = data[0]
        idMovie = data[1]
        rating = (Number) data[2]
        if @ratings[idUser] is undefined then @ratings[idUser] = {}
        @ratings[idUser][idMovie] = rating
        if @averageRating[idUser] is undefined then @averageRating[idUser] = rating else @averageRating[idUser] += rating
    for k of @averageRating
      @averageRating[k] /= Object.keys(@ratings[k]).length

  getRatings: -> @ratings
  getAverageRating: -> @averageRating

#############################################################################################################################

# Get k-nearest neighbourhoods of a user and recommend films using collaborative filtering with Pearson correlation
class Recommender
  constructor: (@ratings, @avgRatings, @myRatings) ->
    @myAvgRating = 0.0
    for k, v of @myRatings
      @myAvgRating += (Number) v
    @myAvgRating /= Object.keys(@myRatings).length

  getNeighbourhood: (k) ->
    @neighbourhood = {}
    for user of @ratings
      matches = []
      for movie of @myRatings
        if @ratings[user][movie] isnt undefined then matches.push movie
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
        if userDen is 0 or otherUserDen is 0 then matchRate = 0 else matchRate = num / (Math.sqrt(userDen) * Math.sqrt(otherUserDen))
      else
        matchRate = 0
      @neighbourhood[user] = matchRate
    tuples = []
    for key of @neighbourhood
      tuples.push [
        key 
        @neighbourhood[key]
      ]
    tuples.sort (a, b) ->
      a = a[1]
      b = b[1]
      if a < b then 1 else if a > b then -1 else 0
    @neighbourhood = {}
    i = 0
    while i < k
      @neighbourhood[tuples[i][0]] = tuples[i][1]
      i++
  
  getRecommendations: (movies, k) ->
    predictedRatings = []
    for movie of movies
      if @myRatings[movie] is undefined
        num = 0.0
        den = 0.0
        for neighbour of @neighbourhood
          if @ratings[neighbour][movie] isnt undefined
            matchRate = @neighbourhood[neighbour]
            num += matchRate * (@ratings[neighbour][movie] - @avgRatings[neighbour])
            den += Math.abs matchRate
        if den > 0.0
          predictedRating = @myAvgRating + num / den
          if predictedRating > 5 then predictedRating = 5
        else
          predictedRating = 0.0
        predictedRatings[movie] = [movie, predictedRating]
    predictedRatings.sort (a, b) ->
      a = a[1]
      b = b[1]
      if a < b then 1 else if a > b then -1 else 0
    predictedRatings.slice 0, k

getRandomInt = (min, max) -> Math.floor(do Math.random * max) + min
getRandomMovie = (numMovies) -> getRandomInt 1, numMovies
getRandomRating = -> getRandomInt 1, 5

#############################################################################################################################

# get recommendations using the parameters below and random personal ratings
NUM_RATINGS = 20
NUM_NEIGHBOURS = 10
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
  while myRatings[idMovie] isnt undefined
    idMovie = getRandomMovie numMovies
  rating = do getRandomRating
  myRatings[idMovie] = rating
  n++

# generate recommendations
recommender = new Recommender do mlRatings.getRatings, do mlRatings.getAverageRating, myRatings
recommender.getNeighbourhood NUM_NEIGHBOURS
recommendations = recommender.getRecommendations do mlMovies.getMovies, NUM_RECOMMENDATIONS

# print results
for recommendation in recommendations
  console.log "#{mlMovies.getMovieName recommendation[0]}: #{recommendation[1]}"