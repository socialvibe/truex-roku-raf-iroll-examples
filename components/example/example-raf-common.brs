function resolveAdPods(data_ as Object) as Object
  di_ = CreateObject("roDeviceInfo")

  truexAd1_ = data_.ad
  truexAd1_.adId = Substitute("truex-{0}", di_.GetRandomUUID())

  truexAd2_ = ParseJson(FormatJson(data_.ad))
  truexAd2_.adId = Substitute("truex-{0}", di_.GetRandomUUID())

  adPodDuration_ = truexAd1_.duration + 29.2 + 30.3 + 32.2

  return [
    {
      viewed         : false,
      rendersequence : "preroll",
      rendertime     : 0, '00:00:00.000'
      duration       : adPodDuration_,
      ads            : [
        data_.ad,
        {
          duration     : 29.2, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-1-1",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
        {
          duration     : 30.3, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-1-2",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
        {
          duration     : 32.2, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-1-3",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
      ]
    },
    {
      viewed         : false,
      rendersequence : "preroll",
      rendertime     : 593, '00:09:53.000'
      duration       : adPodDuration_,
      ads            : [
        data_.ad,
        {
          duration     : 29.2, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-2-1",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
        {
          duration     : 30.3, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-2-2",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
        {
          duration     : 32.2, ' the actual length should be checked with SSAI provider
          streamformat : "mp4",
          adId         : "sample-ad-2-3",
          adServer     : "no_url_imported_ad",
          tracking     : [],
          companionAds : [],
          streams      : [], ' no stream def - actual video embedded into the sample video
        },
      ]
    }
  ]
end function

function handleRAFWrapperEvent(evt_ as Object) as Void
  wrapperEvent_ = evt_.GetData()

  ' save
  m.wrapperEvents.Push(wrapperEvent_)
  ' dispatch
  m.top.wrapperEvent = wrapperEvent_
end function

