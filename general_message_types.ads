-----------------------------------------------------------------------
--                                                                   --
--             G E N E R A L _ M E S S A G E _ T Y P E S             --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package is a storage mechanism for message types.  It is   --
--  principally used by the VNET technology                          --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--                                                                   --
--  This  library is free software; you can redistribute it  and/or  --
--  modify it under terms of the GNU Lesser General  Public Licence  --
--  as  published by the Free Software Foundation;  either  version  --
--  2.1 of the licence, or (at your option) any later version.       --
--  This library is distributed in hope that it will be useful, but  --
--  WITHOUT  ANY  WARRANTY; without even the  implied  warranty  of  --
--  MERCHANTABILITY  or FITNESS FOR A PARTICULAR PURPOSE.  See  the  --
--  GNU Lesser General Public Licence for more details.              --
--  You  should  have  received a copy of the  GNU  Lesser  General  --
--  Public  Licence along with this library.  If not, write to  the  --
--  Free Software Foundation, 59 Temple Place -  Suite 330, Boston,  --
--  MA 02111-1307, USA.                                              --
--                                                                   --
-----------------------------------------------------------------------
with dStrings;  use dStrings;
generic
   type enum_message_types is (<>);
   
 package General_Message_Types is

   type message_string_array_type is
   array (enum_message_types) of text;
      -- Array type for textual names of message types.
   type response_list_array_type is
   array (enum_message_types) of enum_message_types;
      -- Array type for responses to each message type.

   procedure Initialise
   (with_string_array : in message_string_array_type;
   with_response_list : in response_list_array_type);
             -- with_string_array should be loaded with the textual
      -- names of the message types.
      -- with_response_list should be loaded with the response
      -- for each message type.

   function Message_Type(for_message_type : in text)
   return enum_message_types;

   function Message_Type(for_command : in enum_message_types;
   as_a_number : boolean := false) return text;

   function Response_Type(
   for_message_type : in enum_message_types)
   return enum_message_types;

   function Reply_In_Kind(to_the_message_type : in text)
   return text;
      -- reply in the same format as to_the_message_type, i.e. if
      -- it is numeric, then reply in numeric fomat, else reply
      -- in plain english format.

end General_Message_Types;
