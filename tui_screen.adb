  -----------------------------------------------------------------------
--                                                                   --
--                        T U I   S C R E E N                        --
--                                                                   --
--                               B o d y                             --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2020  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package provides a Text User Interface that can  drive  a  --
--  text screen. The text screen can have multiple windows. Writing  --
--  to  the screen is via protected task, meaning that it  is  safe  --
--  for multiple simultaneous writes.                                --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  TUI_Screen  is  free software; you can redistribute  it  and/or  --
--  modify  it  under terms of the GNU General  Public  Licence  as  --
--  published by the Free Software Foundation; either version 2, or  --
--  (at your option) any later version.  TUI Screen is  distributed  --
--  in  hope  that  it will be useful, but  WITHOUT  ANY  WARRANTY;  --
--  without even the implied warranty of MERCHANTABILITY or FITNESS  --
--  FOR  A PARTICULAR PURPOSE.  See the GNU General Public  Licence  --
--  for  more details.  You should have received a copy of the  GNU  --
--  General  Public Licence distributed with TUI Screen.   If  not,  --
--  write  to the Free Software Foundation, 59 Temple  Place  Suite  --
--  330, Boston, MA 02111-1307, USA.                                 --
--                                                                   --
-----------------------------------------------------------------------

with Machine_Dependent_IO;
package body TUI_Screen is

   PREFIX          : constant wide_string    := wide_character'Val(27) & '[';
   LINE_FEED       : constant wide_character := TUI_Constants.C_LINE_FEED;
   CARRIAGE_RETURN : constant wide_character := TUI_Constants.C_C_RETURN;

   procedure Put(n : in positive);  -- Write a decimal number
   protected body Writer is
      procedure Set_x_Pos(to : in positive) is
      begin
         x_position := to;
      end Set_x_Pos;
      procedure Set_y_Pos(to : in positive) is
      begin
         y_position := to;
      end Set_y_Pos;
      function X_Pos return positive is
      begin
         return x_position;
      end X_Pos;
      function Y_Pos return positive is
      begin
         return y_position;
      end Y_Pos;
      procedure Position_Cursor is
      begin
         Machine_Dependent_IO.Put(PREFIX); 
         Put(y_position); Machine_Dependent_IO.Put(";"); 
         Put(x_position); Machine_Dependent_IO.Put("H");
      end Position_Cursor;
      entry Lock when not writing is
      begin
         writing := true;
      end Lock;
      procedure Write(str : in wide_string) is
      begin
         Machine_Dependent_IO.Put ( str );
      end Write;
      procedure Write(ch  : in wide_character) is
      begin
         Machine_Dependent_IO.Put(ch);
      end Write;
      procedure Release is
      begin
         writing := false;
      end Release;
   -- private
      -- Cursor positions
      -- x_position,
      -- y_position  : positive := 1;
      -- writing : boolean := false;
   end Writer;
   
   procedure Put ( n : in positive) is
     -- write a decimal number
   begin
      if n >= 10 then
         Put ( n / 10);
      end if;
      Machine_Dependent_IO. 
                   Put(wide_character'Val(n rem 10 + wide_character'Pos('0')));
   end Put;

   function Main return window_handle is
   begin
      return main_window;
   end Main;
   
   procedure Create(window : out window_handle;
                    at_x, at_y : positive := 1;
                    with_width, with_height : positive := 1) is
   begin
      windows_created := windows_created + 1;
      window.id       := windows_created;
      window.top_left_x    := at_x;
      window.top_left_y    := at_y;
      window.window_width  := with_width;
      window.window_length := with_height;
   end Create;
   
   procedure Set_Keyboard_Device(to : in string) is
   begin
      Machine_Dependent_IO.Set_Keyboard_Device(to => to);
   end Set_Keyboard_Device;
   
   procedure Close_Keyboard_Input is
   begin
      Machine_Dependent_IO.Close_Keyboard_Input;
   end Close_Keyboard_Input;

   procedure Put(ch  : in wide_character;
                 in_window : in out window_handle)is 
     -- Put a character
      h_ch : wide_character;
   begin
      Writer.Lock;
      -- Scroll to the end if necessary
      if in_window.history_lines /= in_window.bottom_visible_history then
         Scroll_Down(by_lines => 
                      in_window.history_lines-in_window.bottom_visible_history,
                     in_window => in_window);
      end if;
      -- Check if we are writing past our history (through a cursor reposition)
      if in_window.current_y > in_window.history_lines + 1 then
         in_window.history_lines := in_window.current_y -1;
         in_window.bottom_visible_history := in_window.history_lines;
      end if;
      -- Check if this is going to make the line wrap
      if (ch /= CARRIAGE_RETURN and ch /= LINE_FEED) and then
         (in_window.current_x > in_window.window_width) then -- wrap text
         in_window.current_x := 1;
         in_window.current_y := in_window.current_y + 1;
      end if;
      -- Check character type
      if ch = CARRIAGE_RETURN then  -- CR = go to beginning of line
         in_window.current_x := 1;
      elsif ch = LINE_FEED then     -- LF = go to new line (and CR)
         in_window.current_x := 1;
         if in_window.current_y >= in_window.window_length then
            -- cursor is at the bottom of the window
            in_window.current_y := in_window.window_length; -- to be sure
            -- scroll the window up one line (i.e. scroll down)
            for line in 1 .. in_window.window_length - 1 loop
               Writer.Set_y_Pos(to => in_window.top_left_y+line-1);
               for col in 1 .. in_window.window_width loop
                  Writer.Set_x_Pos(to => in_window.top_left_x+col-1);
                  Writer.Position_Cursor;
                  h_ch := in_window.history(in_window.history_lines + 2 - 
                                            in_window.window_length+line)(col);
                  Writer.Write(h_ch);
               end loop;
            end loop;
         else  -- not at bottom of window
            in_window.current_y := in_window.current_y + 1;
         end if;
         Writer.Set_y_Pos(to => in_window.top_left_y+in_window.current_y-1);
         -- clear the last line
         for col in 1 .. in_window.window_width loop
            Writer.Set_x_Pos(to => in_window.top_left_x+col-1);
            Writer.Position_Cursor;
            Writer.Write( ' ' );
         end loop;
         Writer.Set_x_Pos(to=> in_window.top_left_x + in_window.current_x - 1);
         Writer.Set_y_Pos(to=> in_window.top_left_y + in_window.current_y - 1);
         Writer.Position_Cursor;
         in_window.history_lines := in_window.history_lines + 1;
         in_window.bottom_visible_history := in_window.history_lines;
      else  -- simple character, not a CR or LF
         Writer.Set_x_Pos(to=> in_window.top_left_x + in_window.current_x - 1);
         Writer.Set_y_Pos(to=> in_window.top_left_y + in_window.current_y - 1);
         Writer.Position_Cursor;
         Writer.Write ( ch );
         in_window.history(in_window.history_lines+1)(in_window.current_x):=ch;
         in_window.current_x := in_window.current_x + 1;
      end if;
      Writer.Release;
   end Put;
   
   procedure Put(ch  : in wide_character) is
   begin
      Put(ch, main_window);
   end Put;

   procedure Put(str : in wide_string;
                 in_window : in out window_handle) is
     -- Put a string
   begin
      for ch_num in str'Range loop
         Put(str(ch_num), in_window);
      end loop;
   end Put;
   
   procedure Put(str : in wide_string) is
   begin
      Put(str, main_window);
   end Put;

   procedure Clear_Screen(of_window : in out window_handle) is
   begin
      Writer.Lock;
      of_window.current_x := 1;
      of_window.current_y := 1;
      Writer.Set_x_Pos(to => of_window.top_left_x);
      Writer.Set_y_Pos(to => of_window.top_left_y);
      Writer.Position_Cursor;
      for row in of_window.top_left_y .. 
                 of_window.top_left_y + of_window.window_length - 1 loop
         for col in of_window.top_left_x ..
                    of_window.top_left_x + of_window.window_width - 1 loop
            Writer.Write(' ');
         end loop;
      end loop;
      -- Writer.Write ( PREFIX & "2J");
      Writer.Set_x_Pos(to => of_window.top_left_x);
      Writer.Set_y_Pos(to => of_window.top_left_y);
      Writer.Position_Cursor;
      Writer.Release;
   end Clear_Screen;

   procedure Clear_Screen is   -- clear the screen
   begin
      Clear_Screen(main_window);
   end Clear_Screen;

   procedure Position_Cursor(col, row : in positive;
                             in_window : in out window_handle) is
   begin
      in_window.current_x := col;
      in_window.current_y := row;
      Writer.Lock;
      Writer.Set_x_Pos(to => in_window.top_left_x+in_window.current_x-1);
      Writer.Set_y_Pos(to => in_window.top_left_y+in_window.current_y-1);
      Writer.Position_Cursor;
      writer.Release;
   end Position_Cursor;
   
   procedure Position_Cursor(col, row : in positive) is
   begin
      Position_Cursor(col, row, main_window);
   end Position_Cursor;

   procedure Scroll_Up(  by_lines : in positive := 1;
                         in_window : in out window_handle) is
   -- scroll the window contents down one line (i.e. scroll selected row up)
      num_lines : natural := by_lines;
      h_ch      : wide_character;
   begin
      while in_window.bottom_visible_history > 0 and num_lines > 0 loop
         for line in 1 .. in_window.window_length - 1 loop
            Writer.Set_y_Pos(to => in_window.top_left_y+line-1);
            for col in 1 .. in_window.window_width loop
               Writer.Set_x_Pos(to => in_window.top_left_x+col-1);
               Writer.Position_Cursor;
               h_ch := in_window.history(in_window.bottom_visible_history - 
                                      in_window.window_length+line)(col);
               Writer.Write(h_ch);
            end loop;
         end loop;
         in_window.bottom_visible_history:= in_window.bottom_visible_history-1;
         num_lines := num_lines - 1;
      end loop;
   end Scroll_Up;
   
   procedure Scroll_Up(by_lines : in positive := 1) is
   begin
      Scroll_Up(by_lines, in_window => main_window);
   end Scroll_Up;
    
   procedure Scroll_Down(by_lines : in positive := 1;
                         in_window : in out window_handle) is
   -- scroll the window contents up one line (i.e. scroll selected row down)
      num_lines : natural := by_lines;
      h_ch      : wide_character;
   begin
      while in_window.bottom_visible_history < in_window.history_lines and 
            num_lines > 0 loop
         for line in 1 .. in_window.window_length - 1 loop
            Writer.Set_y_Pos(to => in_window.top_left_y+line-1);
            for col in 1 .. in_window.window_width loop
               Writer.Set_x_Pos(to => in_window.top_left_x+col-1);
               Writer.Position_Cursor;
               h_ch := in_window.history(in_window.bottom_visible_history - 
                                      in_window.window_length+line)(col);
               Writer.Write(h_ch);
            end loop;
         end loop;
         in_window.bottom_visible_history:= in_window.bottom_visible_history+1;
         num_lines := num_lines - 1;
      end loop;
   end Scroll_Down;
   
   procedure Scroll_Down(by_lines : in positive := 1) is
   begin
      Scroll_Down(by_lines, in_window => main_window);
   end Scroll_Down;

   -- Cursor positions:  These require that all I/O go through
   -- this package (otherwise the position cannot be tracked).
   function  Cursor_X(in_window : in out window_handle) return positive is
   begin
      return in_window.current_x;
   end Cursor_X;
   
   function  Cursor_X return positive is
   begin
      return Cursor_X(in_window => main_window);
   end Cursor_X;

   function  Cursor_Y(in_window : in out window_handle) return positive is
   begin
      return in_window.current_y;
   end Cursor_Y;
   
   function  Cursor_Y return positive is
   begin
      return Cursor_Y(in_window => main_window);
   end Cursor_Y;

   function  Get return wide_character is
      result : wide_character;
   begin
      Machine_Dependent_IO.Get_Immediate ( result );
      Position_Cursor(Writer.X_pos + 1, Writer.Y_pos);
      return result;
   end Get;

   function  Get_Line return wide_string is
      result : wide_character;
   begin
      Machine_Dependent_IO.Get_Immediate ( result );
      if result /= LINE_FEED then  -- more to get
         return result & Get_Line;
      else  -- got it all
         Position_Cursor(1, Writer.Y_pos + 1);
         return "";
      end if;
   end Get_Line;

   function  Currently_Keyed_Line(in_window : in window_handle)
   return wide_string is      -- return what has been keyed/written in so far
   begin
      if in_window.current_x <=1 then
         return "";
      else
         return in_window.history(in_window.history_lines+1)
                                    (1..in_window.current_x);
      end if;
   end Currently_Keyed_Line;

begin
   null;
end TUI_Screen;