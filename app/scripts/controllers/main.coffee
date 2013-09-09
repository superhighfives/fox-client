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

      element.bind 'click', ->
        console.log audio.currentTime

      element.bind 'loadedmetadata', ->
        scope.duration = Math.round audio.duration
        
      element.bind 'timeupdate', ->
        scope.currentTime = Math.round audio.currentTime
        updatedProgress = Math.round (scope.currentTime / scope.duration) * 100
        unless updatedProgress is scope.progress
          scope.progress = Math.round (scope.currentTime / scope.duration) * 100 unless scope.progress is updatedProgress
          scope.$apply()

      element.bind 'play', ->
        nextLyricId = 0
        scope.visibleLyrics = []

        watchForChanges = ->
          if scope.lyrics?
            currentTime = scope.currentTime
            nextLyric = scope.lyrics[nextLyricId]
            if(currentTime > nextLyric.time)
              scope.currentLyric = nextLyric
              scope.currentLyric.visible = true
              console.log scope.currentLyric
              scope.$apply()
              nextLyricId++
            if scope.lyrics.length > nextLyricId
              window.requestAnimationFrame(watchForChanges)
            else
              setTimeout ->
                scope.$parent.ended = true
                scope.$parent.$apply()
              , 12000

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
        {visible: $scope.lyric.visible, 'no-image': !$scope.lyric.image}

  .directive 'lyric', ->
    (scope, element, attrs) ->
      scope.$watch 'lyric.visible', (isVisible) ->
        if isVisible
          console.log isVisible
          # lyricHeight = element.find('.lyric').height()
          # element.height(lyricHeight)
          # setTimeout ->
          #   element.removeClass('transition-height')
          #   element.css('height', 'auto')
          # , 10000
