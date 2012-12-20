require "rubygems"
require 'drb'
require 'gui/config/environment.rb'
begin
  # ==========================
  # = Create DRB connection  =
  # ==========================
  v_pos="creating DRB connection"
  MYLOGGER.info v_pos
  @adhearsion = DRbObject.new_with_uri "druby://localhost:9050"
  # ==========================
  # = Find all pending faxes =
  # ==========================
  v_pos="Looking for pending faxes"
  MYLOGGER.info v_pos
  Fax.to_process.each do |fax|
    MYLOGGER.info "Processing fax"
    MYLOGGER.debug fax.to_yaml
    # Check if we have a free FaxChannel
    done=false
    retry_counter=0
    v_pos="searching for free fax Channel"
    while !done
      # get the first idle channel
      @channel=FaxChannel.find_by_state("idle")
      if !@channel.blank?
        MYLOGGER.info "Found free channel #{@channel.to_yaml}"
        v_pos="Assigning channel to fax"
        MYLOGGER.info v_pos
        fax.update_attribute(:fax_channel_id, @channel.id)
        #change the state
        v_pos="Changing channel state"
        MYLOGGER.info v_pos
        @channel.sending!
        done=true
      else
        MYLOGGER.info "No free channel found, sleeping (#{retry_counter})"
        sleep 20
        retry_counter+=1
        if retry_counter > 5
          v_pos="All fax channels busy, giving up"
          MYLOGGER.info v_pos
          raise "AllChannelsBusy"
        end
      end
    end
    # Todo: add some number formating here
    v_pos="Originating Call to #{fax.dest}"
    MYLOGGER.info v_pos
    call_number="SIP/lcx/#{fax.dest}"
    callerid="#{fax.localstationid}"
    result = @adhearsion.originate({ :channel   => "#{call_number}",
      :context    => "sendfax",
      :extension => 's',
      :priority  => 1,
      :callerid  => "#{callerid}",
      :async => false,
      :variable  => "fax_id=#{fax.id}" })
    # not sure what to do with the result, just log it
    puts "Done"
    MYLOGGER.info "DONE"
    # puts result.to_yaml
  end
  
rescue Exception => e
  MYLOGGER.info "*"*50
  MYLOGGER.info "We crashed during #{v_pos} / #{e.message}"
  MYLOGGER.info e.backtrace.inspect
  MYLOGGER.info "*"*50
  #raise
end
