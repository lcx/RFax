# REMEMBER to restart workling after adding a new one
# RAILS_ENV=development script/workling_client restart
# RAILS_ENV=production script/workling_client restart
require 'drb'
require 'mail'
#require 'carrot'

class FaxWorker < Workling::Base
  def send_fax(options)
    begin
      v_pos="send_fax Start"
      MYLOGGER.info v_pos
      MYLOGGER.debug options.to_yaml
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
        begin
          result = @adhearsion.originate({ :channel   => "#{call_number}",
            :context    => "sendfax",
            :extension => 's',
            :priority  => 1,
            :callerid  => "#{callerid}",
            :async => false,
            :variable  => "fax_id=#{fax.id}" })
          # not sure what to do with the result, just log it
        rescue Exception => e
          # there was an error originating the call ! 
          fax.failed_originate
        end        
        puts "Done"
        MYLOGGER.info "DONE"
        # puts result.to_yaml
      end      
      MYLOGGER.info "DONE"
    rescue Exception => e  
      MYLOGGER.fatal "Fax Worker/send_fax: We crashed during #{v_pos} / #{e.message}"
      MYLOGGER.debug e.backtrace.inspect
      Lcx.notify("send_fax: We crashed during #{v_pos}")
      raise
    end
  end
  
  def send_confirmations(options)
    begin
      v_pos="send_confirmations Start"
      MYLOGGER.info v_pos
      MYLOGGER.debug options.to_yaml
      # Loop through all faxes that need a confirmation mail sent (all faxes send successfully or failure)
      Fax.to_confirm.each do |fax|
        v_pos="Processing fax #{fax.id}"
        MYLOGGER.info v_pos
        if !fax.sender.blank?
          v_pos="preparing mail to #{fax.sender} with attachment #{fax.attachment.path(:faxpdf)}"
          MYLOGGER.info v_pos
          # change the state of the mails after sending
          if fax.success?
            fax.send_success_confirmation
          elsif fax.failed?
            fax.send_failure_confirmation
          end
        else
          MYLOGGER.error "Sender for fax #{fax.id} is empty"
        end # !fax.sender.blank?
      end
      MYLOGGER.info "DONE"
    rescue Exception => e  
      MYLOGGER.fatal "Fax Worker/send_confirmations: We crashed during #{v_pos} / #{e.message}"
      MYLOGGER.debug e.backtrace.inspect
      Lcx.notify("Send SMS: We crashed during #{v_pos}")
      raise
    end
  end
end


