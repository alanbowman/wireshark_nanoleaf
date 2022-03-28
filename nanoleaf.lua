nanoleaf_protocol = Proto("Nanoleaf", "Nanoleaf Touch Stream")

local touch_types = {
    [0] = "hover",
    [1] = "down",
    [2] = "hold",
    [3] = "up",
    [4] = "swipe"
}

num_panels = ProtoField.uint16("nanoleaf.num_panels", "numPanels", base.DEC)
panel_id = ProtoField.uint16("nanoleaf.panelid", "panelID", base.DEC)
touch_event = ProtoField.uint8("nanoleaf.touch_event", "touch", base.DEC, touch_types, 0x70)
touch_pressure = ProtoField.uint8("nanoleaf.touch_pressure", "pressure", base.DEC, NULL, 0x0f)
panel_dest = ProtoField.uint16("nanoleaf.paneldest", "panelDestination", base.DEC)
nanoleaf_protocol.fields = { num_panels, panel_id, panel_dest, touch_event, touch_pressure }

function nanoleaf_protocol.dissector(buffer, pinfo, tree)
    length = buffer:len()
    if length==0 then return end

    pinfo.cols.protocol = nanoleaf_protocol.name

    local subtree = tree:add(nanoleaf_protocol, buffer(), "Nanoleaf Touch Stream Data")
    subtree:add(num_panels, buffer(0,2))

    local panels = buffer(0,2):uint()

    for i=0,panels-1,1
    do
        subtree:add(panel_id, buffer(2 + (5 * i),2))
        subtree:add(touch_event, buffer(4 + (5 * i),1))
        subtree:add(touch_pressure, buffer(4 + (5 * i),1))
        subtree:add(panel_dest, buffer(5 + (5 * i),2))

        pinfo.cols.info:append(" " .. tostring(buffer(2 + (5 * i),2):uint()))
    end
end

local udp_port = DissectorTable.get("udp.port")
udp_port:add(12345, nanoleaf_protocol)