data heart_2 ;
length AgeCHDdiag 3 DeathCause $30 ;
set sashelp.heart(rename=(ageatdeath = Agedeath ageatstart =Agestart)) ;
label sex = 'Gender';
run;

%macro get_var_dist (data_1, data_2);
proc contents data = &data_1. out = _content(keep = Name Type length label); run;

proc contents data = &data_2. out = _2content(keep = Name Type length label);run;

data comparision;
	merge 
		_content(in = in1 rename=(Type = typ1 length = len1 label = lab1))
		_2content(in = in2 rename=(Type = typ2 length = len2 label = lab2));
	by name;
   ds1 = 1; ds2 = 1;
   if in1 and not in2 then ds2 = 0; 
   else if in2 and not in1 then ds1 = 0;
  
   length MSG $200;
   /* add background color */
   if ds1=ds2=1 then
   select;
      when(Typ1 ne Typ2) do; ds1=2; ds2=2; MSG = catx(' ','Type1=', typ1, '; Type2=', typ2, ';'); end;
      when(Len1 ne Len2) do; ds1=3; ds2=3; MSG = catx(' ','Length1=', Len1, '; Length2=', Len2, ';'); end;
      when(Lab1 ne Lab2) do; ds1=4; ds2=4; MSG = catx(' ','label1=', lab1, '; label2=', lab2, ';'); end;
      otherwise; 
   end;
   
   label
      Name = 'Column Name'
      ds1 = 'SASHELP.heart'
      ds2 = 'WORK.heart2'
      ;
run;
proc format;
   value chmark
      0   = '(*ESC*){unicode "2718"x}'
      1-4 = '(*ESC*){unicode "2714"x}'
      ;
   value chcolor
      0   = red
      1-4 = green
      ;
   value bgcolor
      2 = 'cxffccbb'
      3 = 'cxffe177'
      4 = 'cxd4f8d4' 
      ;
run;

title 'Compare table structure difference';
proc print data=comparision label noobs;
   var Name ;
   var ds1 ds2 / style={color=chcolor. backgroundcolor=bgcolor. just=center fontweight=bold width=120px};
   var msg;
   format ds1 ds2 chmark.;
run;



%mend get_var_dist;

options symbolgen mlogic mprint;

%get_var_dist(data_1 = sashelp.heart, data_2 = heart_2);