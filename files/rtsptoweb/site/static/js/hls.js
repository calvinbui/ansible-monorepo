document.addEventListener('DOMContentLoaded', function () {
  const videoPlayer = document.getElementById('videoPlayer');
  const url = '/stream/driveway/channel/0/hlsll/live/index.m3u8';

  let isSafari = navigator.vendor && navigator.vendor.indexOf('Apple') > -1 && navigator.userAgent && navigator.userAgent.indexOf('CriOS') == -1 && navigator.userAgent.indexOf('FxiOS') == -1;

  if (isSafari && videoPlayer.canPlayType('application/vnd.apple.mpegurl')) {
    videoPlayer.src = url;
    videoPlayer.load();
  } else if (Hls.isSupported()) {
    let hlsplayer = new Hls({
      manifestLoadingTimeOut: 60000
    });
    hlsplayer.loadSource(url);
    hlsplayer.attachMedia(videoPlayer);
  } else {
    document.body.innerHTML = "Your browser does not support HLS videos";
  }
})
