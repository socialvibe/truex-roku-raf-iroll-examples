function resolveAdPods(data_ as Object) as Object
  truexAd_ = data_.ad

  return [{
    viewed         : false,
    rendersequence : "preroll",
    rendertime     : 0,
    duration       : (truexAd_.duration + 29.2 + 30.3 + 32.2),
    ads            : [
      data_.ad,
      {
        duration     : 29.2, ' the actual length should be checked with SSAI provider
        streamformat : "mp4",
        adId         : "sample-ad-1",
        adServer     : "no_url_imported_ad",
        tracking     : [],
        companionAds : [],
        streams      : [], ' no stream def - actual video embedded into the sample video
      },
      {
        duration     : 30.3, ' the actual length should be checked with SSAI provider
        streamformat : "mp4",
        adId         : "sample-ad-2",
        adServer     : "no_url_imported_ad",
        tracking     : [],
        companionAds : [],
        streams      : [], ' no stream def - actual video embedded into the sample video
      },
      {
        duration     : 32.2, ' the actual length should be checked with SSAI provider
        streamformat : "mp4",
        adId         : "sample-ad-3",
        adServer     : "no_url_imported_ad",
        tracking     : [],
        companionAds : [],
        streams      : [], ' no stream def - actual video embedded into the sample video
      },
    ]
  }]
end function

function handleRAFWrapperEvent(evt_ as Object) as Void
  wrapperEvent_ = evt_.GetData()

  ' save
  m.wrapperEvents.Push(wrapperEvent_)
  ' dispatch
  m.top.wrapperEvent = wrapperEvent_
end function

