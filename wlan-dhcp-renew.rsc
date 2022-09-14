# Renew DHCP lease on wlan interface if registration AP-MAC was changed

/system script
remove [find name=wlan-dhcp-renew]
add name=wlan-dhcp-renew source={
  :local IF wlan1

  :global WREGLASTMAC
  :local WREGCURMAC [/interface wireless registration-table print as-value where interface=$IF]
  :if ([:len $WREGCURMAC] > 0) do={:set WREGCURMAC ($WREGCURMAC->0->"mac-address") }

  # TODO: don't renew if $WREGLASTMAC isn't set
  :if ($WREGCURMAC != $WREGLASTMAC) do={
    /ip dhcp-client release [find interface=$IF]
    :set WREGLASTMAC $WREGCURMAC
  }
}
