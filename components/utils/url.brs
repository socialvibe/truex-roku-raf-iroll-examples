function _parseQueryString(qs_ as string, delimiter_ = "&") as object
  result_ = {}
  entries_ = qs_.Split(delimiter_)

  for each entry_ in entries_
    keyValuePair_ = entry_.Split("=")

    if keyValuePair_.Count() = 0 then
      result_[keyValuePair_[0].DecodeUriComponent()] = ""
    else
      result_[keyValuePair_[0].DecodeUriComponent()] = keyValuePair_[1].DecodeUriComponent()
    end if
  end for

  return result_
end function