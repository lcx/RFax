methods_for :dialplan do
  def process_fax(p_call)
    begin
      ahn_log "Fax is being called"
      ahn_log p_call.to_yaml
      v_fax_id = get_variable("fax_id")
      v_channel=p_call.channel
      # search for the Fax in the database and set the status to sending
      v_pos="searching for fax_id #{v_fax_id} with state pending"
      @fax=Fax.find_by_id(v_fax_id)
      if @fax
        # increase the retry counter!
        @fax.increment(:tries)
        # change the state
        @fax.send_fax
      else
        v_pos="fax was not found"
        raise FaxNotFound
      end
      # check if file exists
      v_pos="Checking if Fax file #{@fax.attachment.path(:fax)} exists"
      if File.exist? "#{@fax.attachment.path(:fax)}"
        # set the variable 
        variable "LOCALHEADERINFO" => @fax.localheaderinfo
        # send fax
        v_pos="Starting SendFax"
        execute "SendFax", "#{@fax.attachment.path(:fax)}"
        v_pos="getting FAXSTATUS"
        faxstatus=get_fax_variable(v_channel,"FAXSTATUS")
        #get_variable("FAXSTATUS")
        if faxstatus=="SUCCESS"
          v_pos="getting Fax result VARS"
          faxpages=get_fax_variable(v_channel,"FAXPAGES")
          faxbitrate=get_fax_variable(v_channel,"FAXBITRATE")
          faxresolution=get_fax_variable(v_channel,"FAXRESOLUTION")
          remotestationid=get_fax_variable(v_channel,"REMOTESTATIONID")
          ahn_log "Fax was sent ! #{faxpages} Pages, Bitrate #{faxbitrate}, Resolution #{faxresolution}"
          v_pos="Updating DB attributes"
          @fax.update_attribute(:faxpages,faxpages)
          @fax.update_attribute(:faxbitrate,faxbitrate)
          @fax.update_attribute(:faxresolution,faxresolution)
          @fax.update_attribute(:remotestationid,remotestationid)
          @fax.update_attribute(:faxstatus,faxstatus)
          # change the state
          v_pos="changing fax state after success"
          @fax.send_success
        else
          faxerror=get_fax_variable(v_channel,"FAXERROR")
          @fax.update_attribute(:faxerror,faxerror)
          ahn_log "Fax was NOT sent, retrying"
          # change the state
          v_pos="changing fax state after error"
          if @fax.tries>3
            @fax.send_failed
          else
            @fax.retry
          end
        end
      else
        raise FaxFileNotFound
      end
    rescue Exception => e 
      ahn_log "*"*50
      ahn_log "We crashed in process_fax during #{v_pos} / #{e.message}"
      ahn_log e.backtrace.inspect
      ahn_log "*"*50
    ensure
      # reset the state of the channel
      if !@fax.blank? && @fax.fax_channel.busy?
        @fax.fax_channel.finished!
      end
    end   
  end
  
  def get_fax_variable(p_channel,p_var)
    response = Adhearsion::VoIP::Asterisk.manager_interface.send_action(
      "GetVar",  
      :channel => p_channel,
      :variable => "#{p_var}")
    return response.headers[:Value]
  end
end
