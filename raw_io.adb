
   -- with Ada.Wide_Text_IO;
   package body Raw_IO is
   
      procedure Get_Immediate ( ch : out wide_character) is
         c : wide_character;
      begin
         Ada.Wide_Text_IO.Get_Immediate(c);
         ch := c;
      end Get_Immediate;
   
      procedure Put ( ch : in wide_character) is
      begin
         Ada.Wide_Text_IO.Put(ch);  Ada.Wide_Text_IO.Flush;
      end Put;
   
      procedure Put ( str : in wide_string) is
      begin
         Ada.Wide_Text_IO.Put(str);  Ada.Wide_Text_IO.Flush;
      end Put;
   
      procedure Get_Immediate (file : in Ada.Wide_Text_IO.file_type; 
      ch : out wide_character) is
         c : wide_character;
      begin
         Ada.Wide_Text_IO.Get_Immediate(file, c);
         ch := c;
      end Get_Immediate;
   
      procedure Put (file : in Ada.Wide_Text_IO.file_type; 
      ch : in wide_character) is
      begin
         Ada.Wide_Text_IO.Put(file, ch);  
         Ada.Wide_Text_IO.Flush(file);
      end Put;
   
      procedure Put (file : in Ada.Wide_Text_IO.file_type; 
      str : in wide_string) is
      begin
         Ada.Wide_Text_IO.Put(file, str);
         Ada.Wide_Text_IO.Flush(file);
      end Put;
   
   begin
      null;
   end Raw_IO;
