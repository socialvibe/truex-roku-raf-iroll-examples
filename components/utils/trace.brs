sub trace(msg_ as String, data_ = invalid)
  if m.loggerCat <> invalid then
    category_ = m.loggerCat
  else if m.top <> invalid then
    category_ = m.top.subtype()
  else
    category_ = "unknown"
  end if

  if type(data_) = "<uninitialized>" or data_ = invalid then
    ? " >>> ";category_;" # ";msg_
  else
    ? " >>> ";category_;" # ";msg_;" --- ";data_
  end if
end sub