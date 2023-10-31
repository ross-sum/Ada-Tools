   With Ada.Exceptions;
   with Ada.Text_IO; use Ada.Text_IO;
   with Host_Functions; use Host_Functions;
   procedure Test_Host_Functions is
   
      seconds : constant Duration := 1.0;
   
   begin
      Put_Line("Testing Host Functions.");
      Put_Line("Our Name is '" & Host_Name & "'.");
      Put_Line("Spawning a xemacs command...");
      Execute(app_name => "xemacs", 
         args => "/home/public/pro/ada/tools/test_host_functions.adb");-- ,
   		-- envs => "TERM=xterm");
      Put_Line("It is being done and we are still here.  Delaying...");
      delay 10.0 * seconds;
      Put_Line("Waited 10 seconds.");
      null;
   
      exception
         when Event: Naming_Error =>
            Put_Line(Standard_Error, 
               "Error spawning process.  Error is " &
               Ada.Exceptions.Exception_Message(Event));
         when others =>
            Put_Line(Standard_Error, 
               "Unknown error spawning process.");
   
   end Test_Host_Functions;