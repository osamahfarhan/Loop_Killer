{
:local Time [/system clock get time];
:local eths [:toarray ""];
:foreach n,a in=[/log print as-value where topics=interface,warning ] do={ 
:local F [:find ($a->"time") ":" -1 ];
:local time [:totime ([:pick ($a->"time") ($F-2) ($F+5)]."0")];
:local eth  [:pick ($a->"message") 0 [:find ($a->"message") (":")]];
:if ($time>($Time-00:02:00) && $time<($Time+00:02:00) && [:len $eth]>0) do={:if (($a->"message")~"loop") do={:set ($eths->$eth) (($eths->$eth)+5);};:set ($eths->$eth) (($eths->$eth)+1);};
};
:foreach e,msg in=$eths do={
:log warning ("L000000P )(*0*)( L000000P )(*0*)(  interface = $e , $msg");
:if ($msg>=5) do={
    :beep frequency=1500 length=600ms;:delay 650ms;:beep  length=1800ms;:delay 1850ms;:beep frequency=400 length=200ms;
    :local ID ([/interface find where name="$e"]->0);
    :if ([:len $ID]>0) do={
        :local INT [/interface get $ID];
        :local MAC ([:pick ($INT->"mac-address") 0 9 ].[/system clock get time]);
        :while ([:len [/interface find where mac-address=$MAC]]>0) do={:set $MAC ([:pick ($INT->"mac-address") 0 9 ].[/system clock get time]);:delay 1s;:log warning ("CHANG mac again");};
        :if (($INT->"type")="bridge") do={
            :do {[/interface bridge set [find name=($INT->"name")] auto-mac=no admin-mac=$MAC];:log warning ("CHANG bridge mac from=".($INT->"mac-address")." to=",$MAC);} on-error={:log error ("can not change bridge mac to=",$MAC);};
            :delay 2s;
        };
        :if (($INT->"type")="ether") do={
            :do {[/interface ethernet set [find name=($INT->"name")] mac-address=$MAC];:log warning ("CHANG ether mac from=".($INT->"mac-address")." to=",$MAC);} on-error={:log error ("can not change ether mac to=",$MAC);};
            :delay 2s;
        };
        :local IDB [/interface bridge port find where interface=($INT->"name")];
        :if ([:len $IDB ]>0) do={
            :delay 5s;
            :local MAC ([:pick ($INT->"mac-address") 0 9 ].[/system clock get time]);
            :while ([:len [/interface find where mac-address=$MAC]]>0) do={:set $MAC ([:pick ($INT->"mac-address") 0 9 ].[/system clock get time]);:delay 1s;:log warning ("CHANG mac again");};
            :do {[/interface bridge set [find name=[/interface bridge port get ($IDB->0) bridge]] auto-mac=no  admin-mac=$MAC];:log warning ("CHANG bridge of interface mac to=",$MAC);} on-error={:log error ("can not change bridge mac to=",$MAC);};
        };
    };
    :delay 2s;
};
};
};
