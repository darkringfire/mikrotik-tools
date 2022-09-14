# resolve NTP domain names if clock not synchronized

/system ntp client
set enabled=yes servers=ru.pool.ntp.org
/system script
remove [find name=ntp-resolve]
add name=ntp-resolve source={
  :local DNS 9.9.9.9
  /system ntp client {
    :if ([get status]!="synchronized") do={
      :foreach S in=[get servers ] do={
        :do {:resolve $S server=$DNS} on-error={}
      }
    }
  }
}
/system scheduler
remove [find name=ntp-resolve]
add interval=1m name=ntp-resolve on-event=ntp-resolve start-time=startup
