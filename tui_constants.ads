
   package TUI_Constants is
   
      VDT_MAX_X    : constant := 79;    -- Columns on a VDT
      VDT_MAX_Y    : constant := 25;    -- Lines on a VDT
      WINDOW_MAX_X : constant := 79;    -- Max columns in a window
      WINDOW_MAX_Y : constant := 25;    -- Max lines in a window
   
      C_CURSOR     : constant wide_character := wide_Character'Val(04);
      C_BLANK      : constant wide_character := ' ';
      C_WIN_A      : constant wide_character := '#';
      C_WIN_PAS    : constant wide_character := '+';
      C_EXIT       : constant wide_character := wide_Character'Val(05);  -- ^E
      C_ACTION     : constant wide_character := wide_Character'Val(13);  -- CR
      C_SWITCH     : constant wide_character := wide_Character'Val(09);  -- HT
      C_MENU       : constant wide_character := wide_Character'Val(27);  -- Esc
      C_DEL        : constant wide_character := wide_Character'Val(08);  -- ^B
      C_NO_CHAR    : constant wide_character := wide_Character'Val(00);
      C_WHERE      : constant wide_character := ':';    -- update cursor
   
      C_LEFT       : constant wide_character := wide_Character'Val(12);  -- ^L
      C_RIGHT      : constant wide_character := wide_Character'Val(18);  -- ^R
      C_UP         : constant wide_character := wide_Character'Val(21);  -- ^U
      C_DOWN       : constant wide_character := wide_Character'Val(04);  -- ^D
   
   end TUI_Constants;