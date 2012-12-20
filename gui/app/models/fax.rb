require 'mail'
class Fax < ActiveRecord::Base
  attr_accessible :dest, :attachment
  belongs_to :user
  belongs_to :fax_channel
  # no resiying, just convert to tif
  has_attached_file :attachment, 
    :styles=> { :fax=>{:processors => [:faxtif],:format=>:tif}, 
                :faxpdf=>{:processors => [:faxpdf],:format=>:pdf}, 
                :thumb=>["250x250#",:png]}
  # :convert_options => { :fax => '-compress Fax +antialias -support 0 -filter point -resize 1728 -density 204x98 -monochrome -define quantum:polarity=min-is-white' }  
  # has_attached_file :attachment_processed, 
  #   :styles=> { :faxpdf=>{"",:pdf}, 
  #               :thumb=>["250x250#",:png]}
  named_scope :to_process, :conditions => ["state='pending' OR state='retrying'"] 
  named_scope :to_confirm, :conditions => ["state='success' OR state='failed'"] 
  
  include AASM
  # # acts_as_state_machine :initial => :idle
  aasm_column :state
  # 
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :sending
  aasm_state :retrying
  aasm_state :success
  aasm_state :success_confirmed
  aasm_state :failed
  aasm_state :failure_confirmed

  aasm_event :failed_originate do
    transitions :to => :failed, :from => [:pending,:retrying]
  end
  
  aasm_event :send_fax do
    transitions :to => :sending, :from => [:pending,:retrying]
  end

  aasm_event :retry do
    transitions :to => :retrying, :from => [:pending,:sending]
  end

  aasm_event :send_failed do
    transitions :to => :failed, :from => [:pending,:sending,:retrying]
  end

  aasm_event :send_success do
    transitions :to => :success, :from => [:sending]
  end
  
  aasm_event :resend do
    transitions :to => :pending, :from => [:success,:failed]
  end
  
  aasm_event :send_success_confirmation do
    transitions :to => :success_confirmed, :from => [:success]
  end

  aasm_event :send_failure_confirmation do
    transitions :to => :failure_confirmed, :from => [:failed]
  end
  
  def send_fax
    self.send_fax!
  end
  
  def retry
    self.retry!
  end
  
  def resend
    self.resend!
  end
  
  def failed_originate
    # send a error message
    Lcx.notify("Error originating fax #{self.id}")
    # release the channel
    # switch state
    # self.retry
    self.update_attribute(:faxerror,"Rufnummer nicht erreichbar/Fehlerhaft")
    self.increment!(:tries)
    if self.tries > 3
      self.send_failed
    end
    #FaxWorker.async_send_confirmations
    if !self.blank? && self.fax_channel.busy?
      self.fax_channel.finished!
    end
  end
  
  def send_success
    # send mails
    self.send_success!
    FaxWorker.async_send_confirmations
  end
  
  def send_failed
    # send mails
    self.send_failed!
    FaxWorker.async_send_confirmations
  end

  def send_success_confirmation
    fax=self
    mail = Mail.new do
         from 'fax_confirmation@lcx.at'
           to fax.sender
      subject "Fax an #{fax.dest} wurde erfolgreich verschickt"
         body "Ihr Fax an #{fax.dest} wurde erfolgreich verschickt\nSeiten: #{fax.faxpages}\nAuflösung: #{fax.faxresolution}\nBitrate: #{fax.faxbitrate}\nEmpfänger ID: #{fax.remotestationid}\nSendeversuche: #{fax.tries}"
     if File.exist? "#{fax.attachment.path(:faxpdf)}"
       add_file fax.attachment.path(:faxpdf)
     end
    end
    mail.delivery_method :sendmail
    if mail.deliver!
      self.send_success_confirmation!
    end
  end
  
  def send_failure_confirmation
    fax=self
    mail = Mail.new do
         from 'fax_confirmation@lcx.at'
           to fax.sender
      subject "Fax an #{fax.dest} wurde nicht verschickt"
         body "Ihr Fax an #{fax.dest} konnte leider nicht verschickt werden\nSeiten: #{fax.faxpages}\nFehlerursache: #{fax.faxerror}\nSendeversuche: #{fax.tries}"
     if File.exist? "#{fax.attachment.path(:faxpdf)}"
       add_file fax.attachment.path(:faxpdf)
     end
    end
    mail.delivery_method :sendmail
    if mail.deliver!
      self.send_failure_confirmation!
    end
  end
  
  def before_save
    # remove non numerical chars
    self.dest=self.dest.gsub(/[^0-9]/,"")
  end
end
