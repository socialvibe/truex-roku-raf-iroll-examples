' @override
function startExample() as Boolean
  trace("startExample()", m.data)

  m.video = m.top.findNode("_video")

  setupVideo()
  layoutVideo()

  m.raf = m.top.createChild("RAFSSAITask")
  m.raf.observeFieldScoped("wrapperEvent", "handleRAFWrapperEvent")
  m.raf.view = m.top
  m.raf.video = m.video
  m.raf.truexAdUrl = m.data["truex-ad-tag"]
  m.raf.control = "RUN"

  return true
end function

function setupVideo() as Void
  content_ = CreateObject("roSGNode", "ContentNode")
  content_.id = "content"

  ' content_.streamFormat = "hls"
  ' content_.length = 605
  ' content_.url = "http://video.innovid.com/common/video/timecode_10min_5s_lead/source.m3u8"

  content_.streamFormat = "mp4"
  content_.url = "http://development.scratch.truex.com.s3.amazonaws.com/roku/simon/roku-reference-app-stream-med.mp4"
  content_.length = 1535

  trace("setupVideo()", content_)

  m.video.observeField("position", "handlePlaybackStateChanged")
  m.video.observeField("state", "handlePlaybackStateChanged")

  m.video.notificationInterval = .5
  m.video.enableUI = false
  m.video.content = content_
end function

function layoutVideo() as Void
  trace(Substitute("layoutVideo() -- size: {0}x{1}", _asString(m.size.w), _asString(m.size.h)))

  m.video.width = m.size.w
  m.video.height = m.size.h
  m.video.translation = [0, 0]
end function

function handlePlaybackStateChanged(_evt as Object) as Void
  ' trace(Substitute("handleVideoEvent(state: {0}, position: {1})", _Types_AsString( m.video.position ), m.video.state))
end function
