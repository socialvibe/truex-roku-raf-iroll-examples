function resolveAdPods(truexAdUrl_ as Object) as Object
  di_ = CreateObject("roDeviceInfo")

  truexAd1_ = resolveInteractiveAd(truexAdUrl_)
  truexAd2_ = resolveInteractiveAd(truexAdUrl_)

  adPodDuration_ = truexAd1_.duration + 29.2 + 30.3 + 32.2

  return [
    {
      viewed         : false,
      rendersequence : "preroll",
      rendertime     : 0, '00:00:00.000'
      duration       : adPodDuration_,
      ads            : [
        truexAd1_,
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
        truexAd2_,
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

function resolveInteractiveAd(truexAdUrl_ as String) as Object
  di_ = CreateObject("roDeviceInfo")

  ' resolve macro
  truexAdUrl_ = truexAdUrl_.Replace("ROKU_ADS_TRACKING_ID", Roku_Ads().util.GetRIDA())

  ' make ad request
  adRequest_ = CreateObject("roUrlTransfer")
  adRequest_.SetCertificatesFile("common:/certs/ca-bundle.crt")
  adRequest_.InitClientCertificates()
  adRequest_.SetUrl(truexAdUrl_)
  adRequest_.SetRequest("GET")
  adRequest_.RetainBodyOnError(true)
  adResponse_ = adRequest_.GetToString()

  vast_ = CreateObject("roXMLElement")
  vast_.parse(adResponse_)

  ' get companions
  companions = vast_.Ad.InLine.Creatives.Creative.companionAds.Companion

  ' find one with innovid json config url
  for each companionXml_ in companions
    if companionXml_.StaticResource.Count() = 1 then
      adConfigJsonUrl_ = companionXml_.StaticResource[0].GetText()
      exit for
    end if
  end for

  ' return RAF compatible ad structure
  return {
    duration: 15.6, ' choice_card video duration used in the sample video
    streamFormat: "iroll",
    adserver: "no_url_imported_ad",
    adId: Substitute("truex-{0}", di_.GetRandomUUID()),
    tracking: [],
    streams: [
      {
        mimetype: "application/json",
        width: 16,
        height: 9,
        bitrate: 0,
        url: adConfigJsonUrl_
      }
    ]
  }
end function