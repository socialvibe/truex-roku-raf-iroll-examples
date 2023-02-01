function init() as Void
  m.loggerCat = "Examples"

  trace("init()")

  m.started  = false
  m.disposed = false
  m.ready    = false

  m.example = invalid
  m.exampleData = Invalid

  m.examples = m.top.findNode("_examples")
  m.examples.observeField("itemSelected", "handleExampleSelected")

  m.examples.setFocus(true)
end function

sub start(payload_ as Object)
  trace("start()", payload_)

  m.content = generateContent(payload_.examples)
  m.examples.content = m.content

end sub

sub unload(_)
  trace("unload()")
end sub

sub handleExampleSelected(evt_ as Object)
  m.top.event = { type: "select", data: m.content.getchild(evt_.getData()).data }
end sub

function generateContent(examples_ as Object) as Object
  result_ = CreateObject("roSGNode", "ContentNode")

  for each exampleJson_ in examples_
    example_ = CreateObject("roSGNode", "ContentNode")
    example_.addField("data", "assocarray", false)

    example_.id = exampleJson_.id
    example_.title = exampleJson_.title
    example_.data = exampleJson_

    result_.appendChild(example_)
  end for

  return result_
end function