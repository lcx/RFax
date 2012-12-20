# ===================================================
# = Mail Processor - process incoming mails         =
# = Search incomming mails for PDF attachments      =
# = save the attachments to the database and let    =
# = the fax System take care of the rest            =
# =-------------------------------------------------=
# = Created by Cristian Livadaru on 2010-10-10.     =
# = Copyright (c) 2010 lcX.at. All rights reserved. =
# ===================================================
require 'rubygems'
# require 'bundler/setup'
require 'mail'
require 'tempfile'
require 'pdf/toolkit'
#require 'gui/config/environment.rb'
require File.join(File.dirname(__FILE__), 'gui/config/environment.rb')

class PdfTool< PDF::Toolkit
  def self.concat_and_make_frontpage(title, frontpage, outfile, mail_text, files)
    require 'pdf/writer'
    begin
      v_pos="setipng PDF font and sizes"
      MYLOGGER.info v_pos
      @text_font = "Times-Roman"
      @title_font_size = 17
      @title_vertical_spacing = 15
      @page_font_size = 12
      @page_vertical_spacing = 8
      
      v_pos="Creating new PDF"
      MYLOGGER.info v_pos
      print_pdf = PDF::Writer.new(:paper => "A4")
      print_pdf.margins_pt(36)
      @top_heading_font_position = 10

      v_pos="Creating Frontpage"
      MYLOGGER.info v_pos
      print_pdf.select_font @text_font
      print_pdf.text("<b>#{title}</b>", :font_size => @title_font_size,:justification => :center,:left => @top_heading_font_position)
      print_pdf.move_pointer(@title_vertical_spacing)

      print_pdf.text("#{mail_text}", :font_size => @page_font_size,:justification => :left)

      v_pos="Dumping frontpage to file: #{frontpage}"
      MYLOGGER.info v_pos

      print_pdf.save_as(frontpage)
      command = [frontpage] + files + ['cat','output', outfile]
      v_pos="pdftk Command: #{command.join(' ')}"
      MYLOGGER.info v_pos
      
      raise IOError, "Unknown PDFTK Error command: pdftk #{command.join(' ')}" unless pdftk(*command)

 
    rescue Exception => e
      MYLOGGER.info "*"*50
      MYLOGGER.fatal "We crashed during #{v_pos} / #{e.message}"
      MYLOGGER.debug e.backtrace.inspect
      MYLOGGER.info "*"*50
      raise      
    ensure
      # FileUtils.rm(temppath)
    end
  end
end

begin
  # =========================================================================
  # = dump incomming mails to a file, reread the file and parse attachments =
  # =========================================================================
  v_pos="Receiving mail"
  MYLOGGER.info v_pos
  data = STDIN.readlines
  v_pos="Creating tempfile for mail"
  MYLOGGER.info v_pos
  tmp = Tempfile.new('lfax-in')
  v_pos="Dumping mail to tempfile #{tmp.path}"
  MYLOGGER.info v_pos
  f = File.open("#{tmp.path}", "w") do |f|
    f.puts data
  end
  # now the complete mail including attachments was dumped to a temp file
  v_pos="reading mailfile #{tmp.path}"
  MYLOGGER.info v_pos
  # reread the mail and pass it to the mail gem to parse it
  mail = Mail.read("#{tmp.path}")
  # search for the mail_id in the header and see if that ID is allowed to send! 
  v_pos="Getting mail ID from #{mail.try(:message_id)}"
  MYLOGGER.info v_pos
  mail_id=mail.try(:message_id).split("@")[1]
  mail_sender=mail.try(:from).to_s
  mail_domain=mail.try(:from).to_s.split("@")[1]
  v_pos="Search for mail_id: #{mail_id}"
  MYLOGGER.info v_pos
  #MailHeader.find_by_mail_header(mail_id)
  mail_header=MailHeader.find(:first,:conditions=>["mail_header=? OR mail_sender=? OR mail_domain=?",mail_id,mail_sender,mail_domain])
  if mail_header.blank?
    v_pos="No mailheader found with id: #{mail_id} nor sender: #{mail_sender}"
    MYLOGGER.info v_pos
    raise "MailHeaderNotFound"
  end
  # parse all recipients
  v_pos="Parsing recipients #{mail.to.to_s}"
  MYLOGGER.info v_pos
  # not very nice code!
  recipient=mail.to[0].split("@")[0]
  @attachments=[]
  @attachments_ref=[]
  @tmpfiles=[]
  #if mail.message_id.split
  # loop through all attachments
  mail.attachments.each_with_index do |attach,ii|
    v_pos="Checking attachment mime type"
    MYLOGGER.info v_pos
    #MYLOGGER.debug attach.to_yaml
    if attach.mime_type=="application/pdf" || attach.mime_type=="application/octet-stream" # stupid Outlook! 
      v_pos="Creating tempfile for PDF attachment"
      MYLOGGER.info v_pos
      @tmpfiles[ii]=Tempfile.new(['lfax-pdf','pdf'].compact.join("."))
      tmp = @tmpfiles[ii]
      v_pos="writing attachment to #{tmp.path}"
      MYLOGGER.info v_pos
      tmp.write(attach.decoded)
      v_pos="closing file"
      @attachments<<"#{tmp.path}"
    else
      MYLOGGER.info "** SKIPPING attachment: Attachment mime type was #{attach.mime_type} ignoring this attachment"
    end
  end
  # now that all attachments where saved to a temp file, loop through them and create a new fax for each.
  # ToDo: Put all attachments together and send only one fax ? 
  v_pos="Creating tempfile for frontpage"
  MYLOGGER.info v_pos
  frontpage = Tempfile.new(['lfax-fp','pdf'].compact.join("."))
  v_pos="Creating tempfile for outfile"
  MYLOGGER.info v_pos
  outfile = Tempfile.new(['lfax-outf','pdf'].compact.join("."))
  # close all tempfiles
  @tmpfiles.each do |tmpfile|
    # check if we have a tempfile to close
    if tmpfile
      MYLOGGER.info "closing tempfile #{tmpfile.path}"
      tmpfile.close
    end
  end
  # concat all files and create a frontpage. Result will be in outfile
  PdfTool.concat_and_make_frontpage(mail.subject, frontpage.path, outfile.path, mail.text_part.try(:body).to_s, @attachments)
  # v_pos="Looping through attachments"
  # MYLOGGER.info v_pos
  # @attachments.each do |attachment|
    v_pos="Creating new fax record"
    MYLOGGER.info v_pos
    fax=Fax.new
    fax.dest=recipient
    v_pos="adding attachment"
    MYLOGGER.info v_pos
    fax.attachment=File.new("#{outfile.path}")
    v_pos="adding SenderID based on MailHeader"
    MYLOGGER.info v_pos
    fax.localstationid=mail_header.try(:did).try(:did)
    v_pos="adding sender"
    MYLOGGER.info v_pos
    fax.sender=mail.from.to_s
    v_pos="Saving fax record"
    MYLOGGER.info v_pos
    fax.save
  # end
  FaxWorker.async_send_fax
  MYLOGGER.info "All done!"
rescue Exception => e
  MYLOGGER.info "*"*50
  MYLOGGER.fatal "We crashed during #{v_pos} / #{e.message}"
  MYLOGGER.debug e.backtrace.inspect
  MYLOGGER.info "*"*50
  raise
end