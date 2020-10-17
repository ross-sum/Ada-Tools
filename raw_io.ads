   with Ada.Wide_Text_IO;
   package Raw_IO is
      procedure Get_Immediate ( ch : out wide_character);
      procedure Put ( ch : in wide_character);
      procedure Put ( str : in wide_string);
   
      procedure Get_Immediate (file : in Ada.Wide_Text_IO.file_type; 
      ch : out wide_character);
      procedure Put (file : in Ada.Wide_Text_IO.file_type; 
      ch : in wide_character);
      procedure Put (file : in Ada.Wide_Text_IO.file_type; 
      str : in wide_string);
   end Raw_IO;

