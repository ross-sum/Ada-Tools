   with Ada.Wide_Text_IO;
   package Machine_Dependent_IO is
      procedure Put ( ch  : in wide_character);           -- Put a character
      procedure Put ( str : in wide_string);              -- Put a string
      procedure Get_Immediate( ch : out wide_character);  -- Get a character

      procedure Put (file : in Ada.Wide_Text_IO.file_type;
      ch  : in wide_character);           -- Put a character
      procedure Put (file : in Ada.Wide_Text_IO.file_type;
      str : in wide_string);              -- Put a string
      procedure Get_Immediate(file : in Ada.Wide_Text_IO.file_type;
      ch : out wide_character);           -- Get a character
   end Machine_Dependent_IO;
