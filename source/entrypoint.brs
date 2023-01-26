sub main() 
    m.payload = ParseJson(ReadAsciiFile("pkg:/source/payload.json"))
    m.port = CreateObject("roMessagePort")

    m.screen = CreateObject("roSGScreen")
    m.screen.SetMessagePort(m.port)
    m.screen.Show()

    ? m.payload
    m.scene = m.screen.CreateScene("Main")
    m.scene.callFunc("setup", m.payload)

    eventloop()
end sub

sub eventloop()
    while(true)
        msg_ = wait(0, m.port)
        type_ = type(msg_)

        if type_ = "roSGCScreenEvent" and msg_.isScreenClosed() then
            exit while
        end if
    end while
end sub