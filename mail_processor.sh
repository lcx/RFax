#!/bin/bash
cd /var/rails/fax/current && RAILS_ENV=production /opt/ruby/bin/bundle exec /opt/ruby/bin/ruby /var/rails/fax/current/mail_processor.rb
