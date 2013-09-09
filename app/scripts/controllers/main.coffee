'use strict'

angular.module('foxApp')
  .controller 'MainCtrl', ($scope, $http, $document) ->

    setBarTime = (lyric) -> lyric.time = (3.4 * lyric.time) - 3.4
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
          if(lyric.line)
            setLyricSplit(lyric)
        console.log $scope.lyrics
      .error (data, status, headers, config) ->
        $scope.status = "Hmm, something went wrong. Reload, friend! Reload!"

    getLyrics()

    $scope.start = ->
      $scope.playing = true

    $scope.ready = ->
      $scope.lyricsLoaded

  .directive 'foxAudio', ->
    (scope, element, attrs) ->
      audio = element[0]

      element.bind 'loadedmetadata', ->
        audio.currentTime = 30
        scope.duration = Math.round audio.duration
        
      element.bind 'timeupdate', ->
        scope.currentTime = Math.round audio.currentTime
        updatedProgress = Math.round (scope.currentTime / scope.duration) * 100
        unless updatedProgress is scope.progress
          scope.progress = Math.round (scope.currentTime / scope.duration) * 100 unless scope.progress is updatedProgress
          scope.$apply()

      element.bind 'play', ->
        nextLyricId = 0

        watchForChanges = ->
          if scope.lyrics?
            currentTime = audio.currentTime
            nextLyric = scope.lyrics[nextLyricId]
            if(currentTime > nextLyric.time)
              console.log currentTime
              scope.currentLyric = nextLyric
              scope.currentLyric.visible = true
              scope.$apply()
              nextLyricId++
            if scope.lyrics.length > nextLyricId
              window.requestAnimationFrame(watchForChanges)
            else
              setTimeout ->
                scope.ended = true
                scope.$apply()
              , 6800

        window.requestAnimationFrame(watchForChanges)

      scope.$watch 'playing', ->
        if scope.playing
          audio.play()

      scope.$watch 'lyrics', ->
        if scope.lyrics
          scope.status = "Play"
          scope.lyricsLoaded = true

  .controller 'LyricCtrl', ($scope) ->
      $scope.lyricClass = ->
        {visible: $scope.lyric.visible, 'no-image': !$scope.lyric.image, 'no-text': !$scope.lyric.line, ended: $scope.ended}