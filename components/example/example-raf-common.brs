function resolveAdPods(data_ as Object, adPodType_ = "preroll", renderTime_ = 0) as Object
  ad_ = data_.ad

  return [{
    viewed         : false,
    rendersequence : adPodType_,
    rendertime     : renderTime_,
    duration       : ad_.duration,
    ads            : [ data_.ad ],
    ' ads: [
    '   {
    '     duration     : data_.duration,
    '     streamformat : "iroll",
    '     adId         : "innovid-iroll-1",
    '     adServer     : data_.uri,
    '     tracking     : tracking_,
    '     companionAds : [
    '       ' {
    '       '   width    : size_.w,
    '       '   height   : size_.h,
    '       '   bitrate  : 0,
    '       '   url      : data_.uri,
    '       '   mimetype : "application/json"
    '       ' }
    '     ],
    '     streams : [
    '       {
    '         width    : size_.w,
    '         height   : size_.h,
    '         bitrate  : 0,
    '         url      : data_.uri,
    '         mimetype : "application/json"
    '       }
    '     ]
    '   }
    ' ]
  }]

  ' content_.streamFormat = "hls"
  ' content_.length = 605
  ' content_.url = "http://video.innovid.com/common/video/timecode_10min_5s_lead/source.m3u8"
end function

function handleRAFWrapperEvent(evt_ as Object) as Void
  wrapperEvent_ = evt_.GetData()

  ' save
  m.wrapperEvents.Push(wrapperEvent_)
  ' dispatch
  m.top.wrapperEvent = wrapperEvent_
end function

