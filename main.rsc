{
:local mytime [/system clock get time];
:local eths [:toarray ""];
:local I 1;
:foreach n,a in=[/log print as-value where topics=interface,warning  ] do={ 
:local time [:totime ([:pick ($a->"time") ([:find ($a->"time") ":" -1]-2) ([:find ($a->"time") ":" -1 ]+5)]."0")];
:local eth  [:pick ($a->"message") 0 [:find ($a->"message") (":")]];
:if ($time>($mytime-00:00:30) && $time<($mytime+00:05:00)) do={:set ($eths->$eth) ($a->"message");};
:if ($I=0) do={:log warning "L00P detected";};
:set $I 1;
};
:foreach e,msg in=$eths do={
:log warning "the is L00P  in ether=$e ";
:beep  length=5;
:foreach f in=[/interface ethernet find where name="$e"] do={
    :local m [/interface ethernet get $f mac-address];
    :foreach p in=[/interface bridge port find where interface="$e"] do={
        :local N [/interface bridge port get $p bridge];
        :local AM [/interface bridge get [find where name="$N" ] admin-mac];
            :local nm ([:pick $m 0 9 ].[/system clock get time]);
            :while ([:len [/interface find where mac-address=$nm]]>0) do={:set $nm ([:pick $m 0 9 ].[/system clock get time]);:delay 2s;:log warning "CHANG admin mac loop";};
            :do {[/interface bridge set [find name=$N]  auto-mac=no  admin-mac=$nm];:log warning "CHANG bridge=$N admin-mac=$nm";} on-error={:log error ("can not change admin mac".$nm." of bridge=".$N." ether=".$e);}
    };
};
:delay 15s;
};
};
