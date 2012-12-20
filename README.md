Ruby email2fax gateway
======================

Setup: 
-------

1. Edit startup.rb 
2. Edit environment.rb and set your prowl/growl api keys or remove it if you don't want to use it
3. Edit faxworker and set the correct outgoing trunk (currently "SIP/lcx/#{fax.dest}")
4. do the same to sendfax.rb ... not sure if this is even used anymore, code is a mess! 
5. Fork it, start it, watch it crash, fix, send pull requests :) 

Current features:
------------------

Takes any amount of PDF attachments, converts them to TIFF adds the mail text as cover page and sends it as fax. 

Requirements:
------------------
* Asterisk 
* Fax for Asterisk
* ImageMagik
* Ghostscript. 
* Postfix 
* Some other packages I might have forgotten.

Known bugs: 
-----------

Some Debian Squeeze package didn't work or didn't work as expected after upgrading to squeeze. My Fax server is currently stuck with Debian Lenny. 

Postifx Setup:
--------------

in master.cf add:

fax     unix    -       n       n       -       1       pipe
        user=www-data argv=/var/rails/fax/current/mail_processor.sh ${user} ${sender}

you might need to add something to the transport file

fax.myserver.com   fax

configuring the fax numbers:
----------------------------

create a new service type for Fax: 

    [0] #<ServiceType:0x42d9570> {
                :id => 1,
           :type_no => 1,
              :name => "Fax",
        :created_at => Tue, 12 Oct 2010 09:40:44 CEST +02:00,
        :updated_at => Tue, 12 Oct 2010 09:40:44 CEST +02:00
    }

create a DID: 

#<Did:0x42c1998> {
                 :id => 1,
            :user_id => nil,
                :did => "431xxxxx",
    :service_type_id => 1,
              :state => "",
         :created_at => Tue, 12 Oct 2010 10:34:24 CEST +02:00,
         :updated_at => Tue, 22 Mar 2011 21:03:34 CET +01:00
}

This number will be used as callerID for sending out the fax.

Add Permissions: 

    [ 0] #<MailHeader:0x42b7d08> {
                 :id => 1,
        :mail_header => ...,
            :user_id => nil,
             :did_id => 1,
         :created_at => Tue, 12 Oct 2010 10:34:33 CEST +02:00,
         :updated_at => Tue, 06 Dec 2011 21:47:17 CET +01:00,
        :mail_sender => ...,
        :mail_domain => "lcx.at"
    },


Initialy it was set up to use the mail header. This was some mailheader added by the mail client. 
Unfortunately that didn't work out with everyone so it was extended to enable an email address (mail_sender) or a complete domain "@lcx.at"

This isn't a good solution at all! Please be very carefull what you do here and how you watch it or you might enable bad guys to abuse your fax server to generate fraud calls causing you high costs! 
You have been warned! 

The user stuff isn't used at all right now. 