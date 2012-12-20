class AddMailDomainToMailHeader < ActiveRecord::Migration
  def self.up
    add_column :mail_headers, :mail_domain, :string
  end

  def self.down
    remove_column :mail_headers, :mail_domain
  end
end
