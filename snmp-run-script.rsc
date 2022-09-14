#######################
# needs v7
#######################
:global SNMPscript do={
  :local SCRIPSLISTOID "1.3.6.1.4.1.14988.1.1.8.1.1.2"
  
  :local SOIDS [/tool snmp-walk $a community=$c oid=$SCRIPSLISTOID as-value ]
  
  :foreach I in=$SOIDS do={
    :if ($I->"value" = $s) do={
      :local SOID ($I->"oid")
      :set SOID ([:pick $SOID 0 22]."1".[:pick $SOID 22 [:len $SOID]])
      :local RES ([/tool snmp-get $a community=$c oid=$SOID as-value ]->"value")
      :put $RES
      :return $RES
    }
  }
}

$SNMPscript a=127.0.0.1 c=local s=snmp

