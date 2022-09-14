

### EXPORT ###
/system script
remove [find name=export]
add name=export source={
  :local F ""
  :if ([/file find name=flash type=disk]) do={
    :set F "/flash"
  }
  /system {
    :local id [ identity get name ]
    :local v [ routerboard get upgrade-firmware]
    :put "Device: $id"
    :put "ROS: $v"
    
    :local NTP [ntp client print as-value ]
    :local ntpOk ([:type ($NTP->"last-update-from")]!="nothing" || $NTP->"status"="synchronized")
    :put "NTP synchronized: $ntpOk"
    
    :local EXPCMD
    :if ($ntpOk) do={
      :local allmonths [:toarray "zero,jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec"]
      :local date [ clock get date ]
      :local time [ clock get time ]
      :local h [ :pick $time 0 2 ]
      :local m [ :pick $time 3 5 ]
      :local s [ :pick $time 6 8 ]

      :local Y [ :pick $date 7 11 ]
      :local M "$[ :find $allmonths [ :pick $date 0 3 ] ]"
      :if ([:len $M]<2) do={:set M "0$M"}
      :local D [ :pick $date 4 6 ]

      :put "Export running $Y-$M-$D $h:$m:$s"
      :set EXPCMD "/export file=$F/$id_$v_$Y$M$D-$h$m$s"
    } else={
      :put "WARNING! NTP not configured."
      :set EXPCMD "/export file=$F/$id_$v"
    }
    :do {
      :put "Try $EXPCMD show-sensitive"
      [:parse "$EXPCMD show-sensitive"]
      :put "OK"
    } on-error={
      :put "Error (not v7)"
      :put "Try $EXPCMD"
      [:parse "$EXPCMD"]
      :put "OK"
    }
  }
}

