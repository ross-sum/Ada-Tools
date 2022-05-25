   with Generic_Command_Parameters;
   with Ada.Text_IO;  use Ada.Text_IO;
   with Strings;      use Strings;
   procedure Test_Parameters is
     -- Run using Run File... from within Grasp.
     -- Typical command line might be:
     --   test_parameters --other 2 "the end"
   
      function Version return string is
      begin
         return "1.0.0";
      end Version;
      package Parameters is new Generic_Command_Parameters
      (Version, 
      "p,param,string;i,other,integer;b,ok,boolean;,NONAME1,,,source",
      0,false);
      use Parameters;
   begin
      if Parameters.is_invalid_parameter or
      Parameters.is_help_parameter or
      Parameters.is_version_parameter then
         return;
      end if;
      Put_Line("Test Parameters");
      New_Line;
      Put_Line("Parameter for p is '" & 
         Value(Parameter(flag_type'('p'))) & "'.");
      Put_Line("Parameter for i is '" & 
         Integer'Image(Parameter(Value("other"))) & "'.");
      Put("Parameter for b is '");
      if Parameter(Value("ok")) then
         Put("OK'");
      else
         Put("CANCEL'");
      end if;
      New_Line;
      Put_Line("parameter for b as string is '" & 
         Value(Parameter(flag_type'('b'))) & "'.");
      New_Line;
      Put_Line("The source is '" & 
         Value(Parameter(Value("NONAME1"))) & "'.");
      New_Line;
      exception
         when Help_Parameter | Version_Parameter =>
            null;
   end Test_Parameters;