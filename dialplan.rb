sendfax {
  begin
    v_pos="processing fax"
    # pass the call to the sendfax component, keep the dialplan clean
    process_fax(call)
  rescue Exception => e 
    ahn_log "*"*50
    ahn_log "We crashed during #{v_pos} / #{e.message}"
    ahn_log e.backtrace.inspect
    ahn_log "*"*50
    hangup
  end
}
