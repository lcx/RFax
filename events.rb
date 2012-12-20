##
# In this file you can define callbacks for different aspects of the framework. Below is an example:
##
#
# events.asterisk.before_call.each do |call|
#   # This simply logs the extension for all calls going through this Adhearsion app.
#   extension = call.variables[:extension]
#   ahn_log "Got a new call with extension #{extension}"
# end
#
##
# Asterisk Manager Interface example:
#
# events.asterisk.manager_interface.each do |event|
#   ahn_log.events event.inspect
# end
#
# This assumes you gave :events => true to the config.asterisk.enable_ami method in config/startup.rb
#
##
# Here is a list of the events included by default:
#
# - events.asterisk.manager_interface
# - events.after_initialized
# - events.shutdown
# - events.asterisk.before_call
# - events.asterisk.failed_call
# - events.asterisk.hungup_call
#
#
# Note: events are mostly for components to register and expose to you.
##
require 'mail'
I18n.load_path += Dir[File.dirname(__FILE__) + "/config/locales/*.yml"]
I18n.default_locale = :de

# From http://guides.rubyonrails.org/security.html ( Here is the file name sanitizer from the attachment_fu pluginfu/tree/master: )
def sanitize_filename(filename) 
  # ToDo: this needs some Fixing 
  filename.strip.tap do |name| 
    # NOTE: File.basename doesn't work right with Windows paths on Unix  
    # get only the filename, not the whole path
#    name.sub! /\A.*(\\|\/)/, ''
    name.sub! /(\A.*)\\|\;/, ''  
    # Finally, replace all non alphanumeric, underscore  
    # or periods with underscore  
#    name.gsub! /[^\w\.\-]/, '_'
  end
end 

events.asterisk.manager_interface.each do |event|
  begin
    # ahn_log "="*80
    # ahn_log "In Event loop now with event: #{event.name}"
    # ahn_log "="*80
    if event.name.downcase=="newstate"
      # ahn_log "="*80
      # ahn_log "Eventstate: #{event.headers["State"]}"
      # ahn_log "="*80
      if event.headers["State"] == "Up"
        # can we play something in events.rb? 
        #play "goodbye" no we can't
      end      
    end
    if event.name=="UserEvent"
      ahn_log.events event.inspect
      ahn_log.events event.to_yaml
      ahn_log "*"*50
      ahn_log event.headers.inspect
      ahn_log "*"*50
      ahn_log "%"*50
    
      # get the event name of the UserEvent
      user_event=event.headers["UserEvent"].split("|")
      if !user_event.blank? && user_event[0]=="FaxRcvd"
        # we received a fax, process the parameters
        ahn_log "*"*50
        ahn_log "Fax received, params #{user_event[1]}"
        ahn_log I18n.translate('Fax Received')
        ahn_log "*"*50
        # converting fax to pdf.
        v_pos="Sanatizing Filename"
        ahn_log v_pos
        filename=sanitize_filename(event.headers["filename"])
        # check if the file exists
        if File.exist? filename
          v_pos="Converting fax to pdf"
          ahn_log v_pos
          system("convert #{filename} #{filename.gsub(".tif",".pdf")}")
          # check if the pdf file exists
          if File.exist? filename.gsub(".tif",".pdf")
            v_pos="sending mail"
            ahn_log v_pos
            Mail.deliver do
              from 'fax@lcx.at'
              to 'cristian@lcx.at'
              subject I18n.translate('Fax Received')
              body I18n.translate('Fax Rcv Body')
              add_file filename.gsub(".tif",".pdf")
            end
            ahn_log "Done!"
          else
            ahn_log "*"*50
            ahn_log "Skipping Mail. File #{filename.gsub(".tif",".pdf")} doesn't exist"
            ahn_log "*"*50
          end
        else
          ahn_log "*"*50
          ahn_log "Skipping. File #{filename} doesn't exist"
          ahn_log "*"*50
        end
      elsif !user_event.blank? && user_event[0]=="FaxSend"
        ahn_log "*"*50
        ahn_log "We are in sendfax"
        ahn_log "*"*50        
      end
    end
  rescue Exception => e  
    ahn_log "*"*50
    ahn_log "We crashed during #{v_pos} / #{e.message}"
    ahn_log e.backtrace.inspect
    ahn_log "*"*50
    raise
  end
end
