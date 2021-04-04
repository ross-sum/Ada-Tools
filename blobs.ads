 -----------------------------------------------------------------------
--                                                                   --
--                             B L O B S                             --
--                                                                   --
--                     S p e c i f i c a t i o n                     --
--                                                                   --
--                           $Revision: 1.0 $                        --
--                                                                   --
--  Copyright (C) 2021  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  pacakge  converts  to  and from  Base  64  encoding.   It  --
--  typically assumes the input is an array of byte (a blob).        --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  Base_64 is free software; you can redistribute it and/or modify  --
--  it  under terms of the GNU General Public Licence as  published  --
--  by the Free Software Foundation; either version 2, or (at  your  --
--  option) any later version.  Base_64 is distributed in hope that  --
--  it  will be useful, but WITHOUT ANY WARRANTY; without even  the  --
--  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR  --
--  PURPOSE.  See the GNU General Public Licence for more  details.  --
--  You  should  have  received a copy of the  GNU  General  Public  --
--  Licence distributed with  Urine_Records.  If  not, write to the  --
--  Free  Software  Foundation, 51 Franklin  Street,  Fifth  Floor,  --
--  Boston, MA 02110-1301, USA.                                      --
--                                                                   --
-----------------------------------------------------------------------

package Blobs is
   
   type Byte is mod 256;
   type blob is array(positive range <>) of byte;
   pragma Pack(blob);
   
end Blobs;
