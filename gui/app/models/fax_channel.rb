class FaxChannel < ActiveRecord::Base
  attr_accessible :state
  has_many :faxes
  include AASM
  # # acts_as_state_machine :initial => :idle
  aasm_column :state
  # 
  aasm_initial_state :idle
  aasm_state :idle
  aasm_state :busy

  aasm_event :sending do
    transitions :to => :busy, :from => [:idle]
  end

  aasm_event :finished do
    transitions :to => :idle, :from => [:busy]
  end
  
  def finished
    self.finished!
  end
end
