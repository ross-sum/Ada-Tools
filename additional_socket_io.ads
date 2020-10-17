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
   with Sockets; use Sockets;
   package Additional_Socket_IO is

      ------------------------------------
      -- Character-oriented subprograms --
      ------------------------------------

      function Get (Socket : Socket_FD) return character;
         --  Get a character from the socket

      -------------------------
      -- Enquiry subprograms --
      -------------------------

      type poll_type is (poll_read, poll_urgent_read, poll_write_no_block,
      poll_error, poll_hangup, poll_invalid_request);
      for poll_type use (poll_read => 16#0001#,
      poll_urgent_read => 16#0002#, poll_write_no_block => 16#0004#,
      poll_error => 16#0008#, poll_hangup => 16#0010#,
      poll_invalid_request => 16#0020#);
         -- poll_invalid_request is generated when socket is closed.

      function Status(of_socket : in Socket_FD;
      with_read_method : in poll_type := poll_read) return poll_type;
         -- return the status for the socket, passing in the suggested
         -- poll type method.
      function Poll(Socket : in Socket_FD;
      method : in poll_type := poll_read)
      return boolean;
         -- return true if the poll_type condition is met.  Otherwise,
         -- return false.

      function IP_Address(of_socket : in Socket_FD) return string;
         -- return the IP address (in quad dotted notation) of the
         -- socket.  This is our IP address.

      function Peer_IP_Address(of_socket:in Socket_FD) return string;
         -- return the IP address (in quad dotted notation) of the
         -- machine at the other end of the socket.  This is the
         -- peer that is communicating with us.
         -- This function essentially presents the results of
         -- Get_Peer_Addr from Sockets.Naming in a string format.

   end Additional_Socket_IO;
