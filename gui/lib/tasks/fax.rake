Root = File.expand_path('../../../..', __FILE__)

desc 'Start fax'
task :start do
  exec "bundle exec ahn start #{Root}"
end


desc "Send Pending fax"
task :send_pending => :environment do
  FaxWorker.async_send_fax
end