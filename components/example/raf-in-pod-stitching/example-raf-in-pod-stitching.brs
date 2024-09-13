' @override
function startExample() as Boolean
  trace("startExample()")

  m.rafTask = CreateObject("roSGNode", "RAFInPodStitchingTask")
  m.rafTask.view = m.top
  m.rafTask.adPod = m.data.adPod
  m.rafTask.control = "RUN"

  return true
end function
