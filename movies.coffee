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
