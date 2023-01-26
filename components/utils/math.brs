function _Math_Min(a_ as float, b_ as float) as float
  if a_ > b_ then
    return b_
  else
    return a_
  end if
end function

function _Math_Max(a_ as float, b_ as float) as float
  if a_ > b_ then
    return a_
  else
    return b_
  end if
end function

function _Math_Ceil(value_) as integer
  if Int(value_) = value_ then
    result_ = value_
  else
    result_ = Int(value_) + 1
  end if

  return result_
end function

function _Math_Floor(value_) as integer
  return Int(value_)
end function

function _Math_Round(value_) as integer
  return Cint(value_)
end function