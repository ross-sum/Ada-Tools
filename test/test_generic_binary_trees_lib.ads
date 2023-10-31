
   with dStrings;      use dStrings;
   with Generic_Binary_Trees.Locate;

   package Test_Generic_Binary_Trees_Lib is
   
      package String_Binary_Trees is new
      Generic_Binary_Trees(text); --, 1048576);
      function Comparison(comparitor, contains: text) return Boolean;
      package String_Binary_Trees_Find is new
      String_Binary_Trees.Locate(Comparison);
   
   end Test_Generic_Binary_Trees_Lib;