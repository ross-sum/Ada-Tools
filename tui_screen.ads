 -----------------------------------------------------------------------
--                                                                   --
--                        T U I   S C R E E N                        --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
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

with TUI_Constants;

package TUI_Screen is

   -- History (used with scroll back capability)
   history_size : constant positive :=1000; -- lines
   -- Allow for multiple windows
   type window_handle is limited private;
   function Main return window_handle;
   procedure Create(window : out window_handle;
                    at_x, at_y : positive := 1;
                    with_width, with_height : positive := 1);
   
   -- Text output, cursor control and screen management 
   procedure Put(ch  : in wide_character;
                 in_window : in out window_handle);        -- Put a character
   procedure Put(ch  : in wide_character);  -- Put a character in main_window
   procedure Put(str : in wide_string;
                 in_window : in out window_handle);  -- Put a string
   procedure Put(str : in wide_string);     -- Put a string in the main_window
   procedure Clear_Screen;                     -- clear the screen
   procedure Clear_Screen(of_window : in out window_handle);
   procedure Position_Cursor(col, row : in positive;
                             in_window : in out window_handle);
   procedure Position_Cursor(col, row : in positive);
   procedure Scroll_Up(  by_lines : in positive := 1;
                         in_window : in out window_handle);
   procedure Scroll_Up(  by_lines : in positive := 1);
   procedure Scroll_Down(by_lines : in positive := 1;
                         in_window : in out window_handle);
   procedure Scroll_Down(by_lines : in positive := 1);

   -- Cursor positions:  These require that all I/O go through
   -- this package (otherwise the position cannot be tracked).
   function  Cursor_X(in_window : in out window_handle) return positive;
   function  Cursor_X return positive;  -- X position in main_window
   function  Cursor_Y(in_window : in out window_handle) return positive;
   function  Cursor_Y return positive;  -- Y position in main_window
   
   -- Keyboard input from the text user interface
   procedure Set_Keyboard_Device(to : in string);
   procedure Close_Keyboard_Input;
   function  Get return wide_character;
   function  Get_Line return wide_string;
   function  Currently_Keyed_Line(in_window : in window_handle)
   return wide_string;        -- return what has been keyed/written in so far
   
   private
   
    -- make the writing to the screen task/thread safe
   protected Writer is
      procedure Set_x_Pos(to : in positive);
      procedure Set_y_Pos(to : in positive);
      procedure Position_Cursor;
      function X_Pos return positive;
      function Y_Pos return positive;
      entry Lock;
      procedure Release;
      procedure Write(str : in wide_string);
      procedure Write(ch  : in wide_character);
   private
      -- Cursor positions
      x_position,
      y_position  : positive := 1;
      writing : boolean := false;
   end Writer;

   subtype screen_row is wide_string(1..TUI_Constants.WINDOW_MAX_X);
   type screen_lines is array (1..history_size) of screen_row;
   blank_row     : constant screen_row := (1..TUI_Constants.WINDOW_MAX_X=>' ');
   empty_history : constant screen_lines := (1..history_size=>blank_row);
   type window_handle is record
         id            : natural  := 0;
         top_left_x,
         top_left_y    : positive := 1;
         window_width  : positive := TUI_Constants.WINDOW_MAX_X;
         window_length : positive := TUI_Constants.WINDOW_MAX_Y;
         current_x,
         current_y     : positive := 1;
         history_lines : natural := 0;
         history       : screen_lines;
         bottom_visible_history: natural:= 0;
      end record;
      
   main_window : window_handle := (0,1,1,
                                   TUI_Constants.WINDOW_MAX_X, 
                                   TUI_Constants.WINDOW_MAX_Y,
                                   1, 1,
                                   0, empty_history, 0);
   windows_created : natural := 0;
   
end TUI_Screen;

