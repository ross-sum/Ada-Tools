
   with Raw_IO;
   with TUI_Constants;  use TUI_Constants;
   package body Machine_Dependent_IO is

      procedure Put ( ch  : in wide_character) is
      begin
         Raw_IO.Put( ch );
      end Put;

      procedure Put ( str : in wide_string) is
      begin
         Raw_IO.Put( str );
      end Put;

      procedure Get_Immediate( ch : out wide_character) is
      begin
         Raw_IO.Get_Immediate( ch );
         if ch = wide_character'Val(0) then  -- Function Key
            Raw_IO.Get_Immediate ( ch );
            case ch is
               when 'H'    => ch := C_UP;     -- Up arrow
               when 'P'    => ch := C_DOWN;   -- Down arrow
               when 'M'    => ch := C_RIGHT;  -- Right arrow
               when 'K'    => ch := C_LEFT;   -- Left arrow
               when others => ch := '?';      -- Unknown
            end case;  -- ch
         end if;  -- a function key (ch = 16#00#)
      end Get_Immediate;

      procedure Put (file : in Ada.Wide_Text_IO.file_type;
      ch  : in wide_character) is
      begin
         Raw_IO.Put(file, ch );
      end Put;

      procedure Put (file : in Ada.Wide_Text_IO.file_type;
      str : in wide_string) is
      begin
         Raw_IO.Put(file, str );
      end Put;

      procedure Get_Immediate(file : in Ada.Wide_Text_IO.file_type;
      ch : out wide_character) is
      begin
         Raw_IO.Get_Immediate(file, ch );
         if ch = wide_character'Val(0) then  -- Function Key
            Raw_IO.Get_Immediate ( ch );
            case ch is
               when 'H'    => ch := C_UP;     -- Up arrow
               when 'P'    => ch := C_DOWN;   -- Down arrow
               when 'M'    => ch := C_RIGHT;  -- Right arrow
               when 'K'    => ch := C_LEFT;   -- Left arrow
               when others => ch := '?';      -- Unknown
            end case;  -- ch
         end if;  -- a function key (ch = 16#00#)
      end Get_Immediate;

   begin
      null;
   end Machine_Dependent_IO;
