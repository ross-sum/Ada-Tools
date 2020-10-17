-----------------------------------------------------------------------
--                                                                   --
--                A D D I T I O N A L _ S O C K E T _ I O            --
--                                                                   --
--                            $Revision: 1.1 $                       --
--                                                                   --
--  Copyright (C) 1999,2001  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package enhances the AdaSockets package to provide polling --
--  status and IP address information.                               --
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
with Ada.Streams, Interfaces.C, Interfaces.C.Strings;
with Ada.Unchecked_Conversion;
with Sockets.Thin;           use Sockets.Thin;
with Sockets.Naming;         use Sockets.Naming;
with Sockets.Types;          use Sockets.Types;
--@ with Ada.Text_IO;  -- for debugging
package body Additional_Socket_IO is

   use Ada.Streams, Interfaces.C, Interfaces.C.Strings;

   package C renames Interfaces.C;

   function Poll_Type_To_Short is new
   Ada.Unchecked_Conversion(poll_type, Interfaces.C.short);
   function Short_To_Poll_Type is new
   Ada.Unchecked_Conversion(Interfaces.C.short, poll_type);

   ---------
   -- Get --
   ---------

   function Get (Socket : Socket_FD) return character is
      --  Get a character from the socket
      Byte   : Stream_Element_Array (1 .. 1);
      Char   : Character := ' ';  -- default for input failure
      retries_count : constant positive := 1000;  -- 10 seconds
      count         : natural := 0;
   begin
      while count < retries_count  -- time out for drop out
      -- and then Status(Socket) /= poll_hangup
      and not Poll(Socket, method => poll_read) loop
         count := count + 1;
         delay 0.010;  -- wait 10 milliseconds
      end loop;
      -- if Status(Socket) = poll_hangup then  -- we're dead
         -- null;
         -- raise Sockets.Connection_Closed;
      -- els
      if count >= retries_count
      and not Poll(Socket, method => poll_read) then
         --@ Ada.Text_IO.Put_Line("Exceeded wait time for Socket Get.");
         null;
      end if;
      Receive (Socket, Byte);
      Char := Character'Val (Stream_Element'Pos (Byte (Byte'First)));
      return Char;
   end Get;

   ------------
   -- Status --
   ------------

   -- type poll_type is (poll_read, poll_urgent_read, poll_write_no_block,
   -- poll_error, poll_hangup, poll_invalid_request);

   function Status(of_socket : in Socket_FD;
                   with_read_method : in poll_type := poll_read) return poll_type is
      -- return the status for the socket, passing in the suggested
      -- poll type method.
   
      timeout  : constant C.int := 10;  -- milliseconds
      file_des : aliased pollfd_array(1..1);
      count    : int;
      result   : poll_type;
   begin
      file_des(1).Fd := Get_FD(of_socket);
      file_des(1).events := Poll_Type_To_Short(with_read_method);
      file_des(1).revents := 0;
      count := C_Poll(file_des'Address, 1, timeout);
      -- if method = poll_write_no_block and count > 0 then
      -- Ada.Text_IO.Put(integer'Image(integer(count)));
      -- end if;
      if count > 0 then
         result := Short_To_Poll_Type(file_des(1).revents);
         -- if not result'Valid then
            -- result := poll_invalid_request;
         -- end if;
         return result;
      elsif count = 0 then  -- call timed out and no file descs selected
         return poll_error;
      else  -- < 0 (i.e. -1) = error condition
         return poll_error;
      end if;
   end Status;

   ----------
   -- Poll --
   ----------

   function Poll(Socket : in Socket_FD;
                 method : in poll_type := poll_read) return boolean is
      -- return true if the poll_type condition is met.  Otherwise,
      -- return false.
   begin
      return Status(Socket, method) = method;
   end Poll;

   ----------------
   -- IP_Address --
   ----------------

   function IP_As_String(of_address : in address) return string is
      function To_Number(of_address : in address_component)
      return string is
         radix    : constant address_component := 10;
         a_string : string(1..1);
      begin
         if of_address >= radix then
            return To_Number(of_address / radix) &
               Character'Val(Character'Pos('0') +
                             Integer(of_address rem radix));
         else
            a_string(1) := Character'Val(Character'Pos('0') +
                                         Integer(of_address));
            return a_string;
         end if;
      end To_Number;
   begin
      return To_Number(of_address.H1) & '.' &
         To_Number(of_address.H2) & '.' &
         To_Number(of_address.H3) & '.' &
         To_Number(of_address.H4);
   end IP_As_String;

   function IP_Address(of_socket : in Socket_FD) return string is
      -- return the IP address (in quad dotted notation) of the
      -- other end of the socket.
      the_socket  : aliased sockaddr_in;
      name_length : aliased int := the_socket'Size / 8;
   begin
      if C_Getsockname(Get_FD(of_socket), the_socket'Address,
                       name_length'Access) = failure then
         return "0.0.0.0";  -- failed result
      else
         return IP_As_String(of_address =>
                             To_Address(the_socket.sin_addr));
      end if;
   end IP_Address;

   ---------------------
   -- Peer_IP_Address --
   ---------------------

   function Peer_IP_Address(of_socket : in Socket_FD)
   return string is
      -- return the IP address (in quad dotted notation) of the
      -- machine at the other end of the socket.  This is the
      -- peer that is communicating with us.
      -- This function essentially presents the results of
      -- Get_Peer_Addr from Sockets.Naming in a string format.
   begin
      return IP_As_String(of_address =>
                          To_Address(Get_Peer_Addr(of_socket)));
   end Peer_IP_Address;

begin
   null;
end Additional_Socket_IO;
