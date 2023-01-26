function _isInitialized(value_) as boolean
  return type(value_) <> "<uninitialized>"
end function

function _isString(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifString") <> invalid
end function

function _isInteger(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifInt") <> invalid
end function

function _isFloat(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifFloat") <> invalid
end function

function _isDouble(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifDouble") <> invalid
end function

function _isLongInteger(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifLongInt") <> invalid
end function

function _isBoolean(value_ as dynamic) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifBoolean") <> invalid
end function

function _isArray(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifArray") <> invalid
end function

function _isObject(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifAssociativeArray") <> invalid
end function

function _isNumeric(value_) as boolean
  if not(_isInitialized(value_)) then
    return false
  end if

  return GetInterface(value_, "ifInt") <> invalid or GetInterface(value_, "ifFloat") <> invalid or GetInterface(value_, "ifLongInt") <> invalid or GetInterface(value_, "ifDouble") <> invalid
end function

function _isScalar(value_) as boolean
  return _isNumeric(value_) or _isBoolean(value_) or _isString(value_)
end function

function _isFunction(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifFunction") <> invalid
end function

function _isEnumerable(value_) as boolean
  return _isInitialized(value_) and GetInterface(value_, "ifEnum") <> invalid
end function

function _isSGNode(value_) as boolean
  return _isInitialized(value_) and type(value_) = "roSGNode"
end function

function _isNonEmptyString(value_) as boolean
  return _isString(value_) and value_.Trim() <> ""
end function

function _isInvalidOrEmptyString(value_) as boolean
  if not(_isInitialized(value_)) or value_ = invalid then
    return true
  end if

  if _isString(value_) and value_ = "" then
    return true
  end if

  return false
end function

function _isEmpty(raw_ as dynamic) as boolean
  if raw_ = invalid then
    return true
  end if

  if _isString(raw_) then
    return (raw_.Trim() = "")
  end if

  return false
end function

function _asString(value_, fallback_ = "") as string
  if _isInitialized(value_) and value_ <> invalid and GetInterface(value_, "ifToStr") <> invalid then
    return value_.ToStr()
  else
    return fallback_
  end if
end function

function _asFloat(value_) as float
  if _isNumeric(value_) then
    return value_
  else if _isString(value_) then
    return value_.toFloat()
  end if

  return 0.0
end function

function _asInteger(value_ as dynamic, fallback_ = 0) as integer
  if not(_isInitialized(value_)) then
    return fallback_
  end if

  if _isString(value_) then
    return Val(value_, 0)
  end if

  if _isNumeric(value_) then
    return value_
  end if

  return fallback_
end function

function _asLongInteger(value_) as longinteger
  if _isLongInteger(value_) or _isInteger(value_) then
    return 0& + value_
  else if _isString(value_) and value_.Trim() <> "" then
    return ParseJSON("[" + value_ + "]")[0]
  end if

  return 0&
end function