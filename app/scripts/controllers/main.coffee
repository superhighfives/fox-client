'use strict'

angular.module('foxApp')
  .controller 'MainCtrl', ($scope, $http) ->

    setBarTime = (lyric) -> lyric.time = (6.4 * lyric.time)
    setLyricSplit = (lyric) ->
      if lyric.image
        pattern = new RegExp "^(.*)(#{lyric.keyword})(.*)$", "im"
        lyric.processed = lyric.line.match pattern

    getLyrics = ->
      $scope.status = "Fetching data..."
      $http.get("/data/data.json").success (data) ->
        $scope.lyrics = data.lyrics
        for lyric in $scope.lyrics
          setBarTime(lyric)
          setLyricSplit(lyric)
        console.log $scope.lyrics
      .error (data, status, headers, config) ->
        $scope.status = "Hmm, something went wrong. Reload, friend! Reload!"

    getLyrics()

  .directive 'foxAudio', ->
    (scope, element, attrs) ->
      audio = element[0]
      audio.play()
      element.bind 'timeupdate', ->
        console.log audio.currentTime


