
   with dStrings;      use dStrings;
   with Generic_Binary_Trees_With_Data.Locate;

   package Test_Generic_Binary_Trees_With_Data_Lib is
   
      type mytext is new ttext;
      package String_Binary_Trees is new
      Generic_Binary_Trees_With_Data(text,mytext);
      function Comparison(comparitor, contains: text) return Boolean;
      package String_Binary_Trees_Find is new
      String_Binary_Trees.Locate(Comparison);
   
   end Test_Generic_Binary_Trees_With_Data_Lib;
