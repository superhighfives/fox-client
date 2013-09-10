(function(){"use strict";angular.module("foxApp",[])}).call(this),function(){"use strict";angular.module("foxApp").controller("MainCtrl",["$scope","$http","$document",function(a,b){var c,d,e,f,g,h,i;return f=window.location.toString().match(/localhost/)&&!window.location.toString().match(/\?live=1/)?"http://localhost:5000/data.json?callback=JSON_CALLBACK":"http://fox-server.herokuapp.com/data.json?callback=JSON_CALLBACK",g=window.requestAnimationFrame||window.mozRequestAnimationFrame||window.webkitRequestAnimationFrame||window.msRequestAnimationFrame,window.requestAnimationFrame=g,h=function(a){return a.time=3.429*a.time-3.429},i=function(a){var b;return a.keyword?(b=new RegExp("^(.*)("+a.keyword+")(.*)$","im"),a.processed=a.line.match(b)):void 0},d=3,e=1,c=function(){return a.status="Fetching gifs...",b.jsonp(f+"").success(function(b){return setTimeout(function(){var c,d,e,f;for(a.lyrics=b,f=a.lyrics,d=0,e=f.length;e>d;d++)c=f[d],h(c),c.line&&i(c);return a.$apply()},3e3)}).error(function(){return e>=d?a.status="Hmm, something went wrong. Reload, or try again soon!":(e+=1,setTimeout(function(){return c()},300))})},c(),a.start=function(){return a.lyricsLoaded?a.playing=!0:void 0},a.ready=function(){return a.lyricsLoaded}}]).directive("foxAudio",function(){return function(a,b){var c;return c=b[0],b.bind("loadedmetadata",function(){return c.currentTime=30,a.duration=Math.round(c.duration)}),b.bind("timeupdate",function(){var b;return a.currentTime=Math.round(c.currentTime),b=Math.round(100*(a.currentTime/a.duration)),b!==a.progress?(a.progress!==b&&(a.progress=Math.round(100*(a.currentTime/a.duration))),a.$apply()):void 0}),b.bind("play",function(){var b,d;return b=0,d=function(){var e,f;return null!=a.lyrics?(e=c.currentTime,f=a.lyrics[b],e>f.time&&(a.currentLyric=f,a.currentLyric.visible=!0,a.$apply(),b++),a.lyrics.length>b?window.requestAnimationFrame(d):setTimeout(function(){return a.ended=!0,a.$apply()},6800)):void 0},window.requestAnimationFrame(d)}),a.$watch("playing",function(){return a.playing?c.play():void 0}),a.$watch("lyrics",function(){return a.lyrics?(a.status="Play",a.lyricsLoaded=!0):void 0})}}).controller("LyricCtrl",["$scope",function(a){return a.lyricClass=function(){return{visible:a.lyric.visible,"no-image":!a.lyric.image,"no-text":!a.lyric.line,ended:a.ended}},a.imageStyle=function(){return a.lyric.image?{"background-image":"url("+a.lyric.image.url+")"}:void 0}}])}.call(this);