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

    $scope.start = ->
      $scope.playing = true

  .directive 'foxAudio', ->
    (scope, element, attrs) ->
      audio = element[0]

      element.bind 'loadedmetadata', ->
        scope.duration = Math.round audio.duration
        
      element.bind 'timeupdate', ->
        scope.currentTime = Math.round audio.currentTime
        updatedProgress = Math.round (scope.currentTime / scope.duration) * 100
        unless updatedProgress is scope.progress
          scope.progress = Math.round (scope.currentTime / scope.duration) * 100 unless scope.progress is updatedProgress
          scope.$apply()

      scope.$watch 'playing', ->
        if scope.playing
          audio.play()
