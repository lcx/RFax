module Lcx
  def Lcx.notify(p_error_msg)
    # Initialise growl
    GROWL_K.notify "Fax LcX", "Fax LcX", "#{p_error_msg}" 
    v_prowl=PROWL_K
    if !v_prowl.valid?
      v_prowl = Prowl.new(:apikey => "YOUR API CODE HERE", :application => "Fax LcX")
    end

    v_prowl.add(:application => "Fax LcX",
      :event => "Error",
      :description => "#{p_error_msg}",
      :priority => 2)  
  end
end