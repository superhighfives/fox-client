'use strict'

angular.module('foxApp')
  .controller 'MainCtrl', ($scope, $http, $document) ->


    gif_url = if window.location.toString().match(/localhost/) and not window.location.toString().match(/\?live=1/)
      "http://localhost:5000/data.json?callback=JSON_CALLBACK"
    else
      "http://fox-server.herokuapp.com/tweets.json?callback=JSON_CALLBACK"

    setBarTime = (lyric) -> lyric.time = (3.4 * lyric.time) - 3.4
    setLyricSplit = (lyric) ->
      if lyric.keyword
        pattern = new RegExp "^(.*)(#{lyric.keyword})(.*)$", "im"
        lyric.processed = lyric.line.match pattern

    gif_fetch_attempt_limit = 3
    gif_fetch_attempts = 1

    getLyrics = ->
      $scope.status = "Fetching gifs..."
      $http.get("http://localhost:5000/data.json").success (data) ->
        $scope.lyrics = data
        for lyric in $scope.lyrics
          setBarTime(lyric)
          if(lyric.line)
            setLyricSplit(lyric)
      .error (data, status, headers, config) ->
        if gif_fetch_attempts >= gif_fetch_attempt_limit
          $scope.status = "Hmm, something went wrong. Reload, or try again soon!"
        else
          gif_fetch_attempts += 1
          setTimeout (-> getLyrics()), 1000

    getLyrics()

    $scope.start = ->
      $scope.playing = true

    $scope.ready = ->
      $scope.lyricsLoaded

  .directive 'foxAudio', ->
    (scope, element, attrs) ->
      audio = element[0]

      element.bind 'loadedmetadata', ->
        # audio.currentTime = 160
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
      $scope.imageStyle = ->
        {'background-image': 'url(' + $scope.lyric.image.url + ')'} unless !$scope.lyric.image