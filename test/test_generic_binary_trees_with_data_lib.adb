  
   package body Test_Generic_Binary_Trees_With_Data_Lib is
   
      function Comparison(comparitor, contains: text) 
      return Boolean is
      begin
         return Locate(fragment=> contains, within=> comparitor) = 1;
      end Comparison;
   
   begin
      null;
   end Test_Generic_Binary_Trees_With_Data_Lib;
