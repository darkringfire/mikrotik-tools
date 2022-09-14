# Port knocking hosts by TCP

/system script
remove [find name=knock-tcp]
add name=knock-tcp source={
  :local HOSTS ({})
  :set HOSTS ($HOSTS,{"my.host"=100,200})
  
  :foreach HOST,SEQ in=$HOSTS do={
    :foreach PORT in=$SEQ do={
      :do { /tool fetch "http://$HOST:$PORT" output=none duration=1 } on-error={}
    }
  }
}
