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
