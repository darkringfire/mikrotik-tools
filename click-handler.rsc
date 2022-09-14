# Handle clicking Mode or Reset button
# Handler read click sequence and import script named by template:
# C(\.\d+)+-.+\.rsc

# the script is searched in the flashdrive root if it exists, 
# otherwise in the root directory

# Usage:
# 1. click the button several times to enter one number
# 2. wait for the USR LED to flash
# 3. repeat 1 and 2 to enter other numbers
# 4. wait until the LED stops flashing
# 5. PROFIT! script started

# as example: C.1.2.3-script.rsc will be runing by clicking:
# !--!!--!!!

### CLICK ###
/system script
remove [find name=click]
add name=click source={
  # maximum delay in digit enter
  :local SHORT 2
  # maximum delay between digits in sequence
  :local LONG 3
  :blink duration=0

  :global CLICKID
  :if ([:typeof $CLICKID]!="num") do={
    :set CLICKID 0
  }
  :set CLICKID ($CLICKID+1)
  :local MYID $CLICKID

  :global CLICKVAL
  :if ([:typeof $CLICKVAL]!="num") do={
    :set CLICKVAL 0
  }
  :set CLICKVAL ($CLICKVAL+1)

  :global CLICKARR
  :if ([:typeof $CLICKARR]!="array") do={
    :set CLICKARR [:toarray ""]
  }

  :log info ("click ID: $MYID; click array: ".[:tostr $CLICKARR]."; value: $CLICKVAL")

  # wait increase
  :delay $SHORT
  :if ($CLICKID = $MYID) do={
    :set CLICKARR ($CLICKARR,$CLICKVAL)
    :log info ("new click array: ".[:tostr $CLICKARR])
    :set CLICKVAL
    
    # wait action
    :blink duration=$LONG
    :delay $LONG
    :if ($CLICKID = $MYID) do={
      :local PREFIX "/C"
      :if ([/file find name=flash type=disk]) do={
        :set PREFIX "/flash$PREFIX"
      }
      :foreach N in=$CLICKARR do={
        :set PREFIX "$PREFIX.$N"
      }
      :set PREFIX "$PREFIX-"
      :set CLICKID
      :set CLICKARR
      
      /file {
        :local FS [find name~"^$PREFIX.*\\.rsc\$"]
        :if ($FS) do={
          :local FN [get ($FS->0) name]
          :log info ("Action! $FN")
          /import $FN
        } else={
          :log info ("No file! $PREFIX")
        }
      }
    }
  }
}
