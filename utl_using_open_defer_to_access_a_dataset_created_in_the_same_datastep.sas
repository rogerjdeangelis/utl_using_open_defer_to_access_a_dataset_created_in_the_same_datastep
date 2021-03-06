Using open_defer to access a dataset created in the same datastep

  Two solutions
     1. dosubl proc sort
     2. dosubl hash

see
https://stackoverflow.com/questions/47863741/how-to-sort-data-using-data-step-in-sas


I like the kind of out of the box questions new SAS users ask?

We are using 'open=defer' to access a dataset created in the same datastep.

INPUT
=====

 SASHELP.CLASS total obs=19                         RULES (Add weight total to each ob)
                                                          112.5+84+98+102.5+102.5+83
   NAME       SEX    AGE    HEIGHT    WEIGHT       SUMWGT

   Alfred      M      14     69.0      112.5        582.5
   Alice       F      13     56.5       84.0        582.5
   Barbara     F      13     65.3       98.0        582.5
   Carol       F      14     62.8      102.5        582.5
   Henry       M      14     63.5      102.5        582.5
   James       M      12     57.3       83.0        582.5


PROCESS (All the code)
======================

   data want(drop=rc);;
    retain sumwgt .;
    set sashelp.class(in=one) havSrt(in=two) open=defer;
    sumwgt=sum(sumwgt,weight);
    if _n_ =1 then do;
      rc=dosubl('
            proc sort data=sashelp.class out=havSrt;
              by sex age;
            run;quit;
      ');
    end;
    if two then output;
   run;quit;

   hash solution at end;

OUTPUT
====

 WORK.WANT total obs=19

    SUMWGT    NAME       SEX    AGE    HEIGHT    WEIGHT

    1951.0    Joyce       F      11     51.3       50.5
    2035.5    Jane        F      12     59.8       84.5
    2112.5    Louise      F      12     56.3       77.0
    2196.5    Alice       F      13     56.5       84.0
    2294.5    Barbara     F      13     65.3       98.0
    2397.0    Carol       F      14     62.8      102.5
    2487.0    Judy        F      14     64.3       90.0

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

  sashelp.class inside datastep script

*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

*               _
 ___  ___  _ __| |_
/ __|/ _ \| '__| __|
\__ \ (_) | |  | |_
|___/\___/|_|   \__|

;

data want(drop=rc);
 retain sumwgt .;
 set sashelp.class(in=one) havSrt(in=two) open=defer;
 sumwgt=sum(sumwgt,weight);
 if _n_ =1 then do;
   rc=dosubl('
         proc sort data=sashelp.class out=havSrt;
           by sex age;
         run;quit;
   ');
 end;
 if two then output;
run;quit;

*_               _
| |__   __ _ ___| |__
| '_ \ / _` / __| '_ \
| | | | (_| \__ \ | | |
|_| |_|\__,_|___/_| |_|

;

data want;
 retain sumwgt .;
 set sashelp.class(in=one) havSrt(in=two) open=defer;
 sumwgt=sum(sumwgt,weight);
 if _n_ =1 then do;
   rc=dosubl('
      data _null_;
         if 0 then set sashelp.class;
         declare hash sortha(dataset: "sashelp.class", ordered:"a", multidata:"y");
         sortha.definekey ("sex");
         sortha.defineData(all:"yes");
         sortha.definedone();
         sortha.output(dataset:"havSrt");
         stop;
      run;quit;
   ');
 end;
 if two then output;
run;quit;

