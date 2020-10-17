-----------------------------------------------------------------------
--                                                                   --
--                      X M L   P R I M I T I V E S                  --
--                                                                   --
--                       S p e c i f i c a t i o n                   --
--                                                                   --
--                           $Revision: 1.1 $                        --
--                                                                   --
--  Copyright (C) 2003-2020  Hyper Quantum Pty Ltd.                  --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  library  provides a primitive interface for  reading  and  --
--  traversing XML files.  It ssumes the XML file is nested and can  --
--  extract  a nest at any level.  It relies on the  Hyper  Quantum  --
--  library  tools  dStrings (which, these days, is built  on  wide  --
--  unbounded strings, but was developed under Ada 83 when they did  --
--  not exist) and on the standard Wide_Text_IO library.             --
--  You effectively traverse the XML by eating up the nodes.         --
--                                                                   --
--  Version History:                                                 --
--  $Log$
--                                                                   --
--  XML Primitives is free software; you can redistribute it and/or  --
--  modify  it under terms of the GNU  General  Public  Licence  as  --
--  published by the Free Software Foundation; either version 2, or  --
--  (at   your  option)  any  later  version.   XML Primitives   is  --
--  distributed  in  hope that it will be useful,  but  WITHOUT  ANY --
--  WARRANTY; without even the implied warranty of  MERCHANTABILITY  --
--  or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public  --
--  Licence for  more details.  You should have received a copy  of  --
--  the GNU General Public Licence distributed with Port_Logger. If  --
--  not,  write to the Free Software Foundation, 59 Temple Place  -  --
--  Suite 330, Boston, MA 02111-1307, USA.                           --
--                                                                   --
-----------------------------------------------------------------------
with dStrings; use dStrings;
with Ada.Wide_Text_IO;
package XML_Primitives is

   function Strip_Comments(from_text : text) return text;
     -- Strip comments from the text string, which are bounded by
     -- "<!--" and "-->".  The input can be a multi-line block
     -- of text.

   function Get_Nest(for_section : wide_string; from_text : text)
   return text;
      -- Get the full nest specified between the specified <for_section>
      -- and its terminating </for_section>.  This is case sensitive as
      -- per the XML standard that is in force these days.

   function Get_Nest(for_section : wide_string; 
   from_file : Ada.Wide_Text_IO.file_type) return text;
      -- Get the nest, but from a file.  The file can be a UTF8 file.

   procedure Strip_White_Space(from_text : in out text);

   procedure Extract(section : out ttext; with_name : wide_string;
   from_XML: in out text);

end XML_Primitives;