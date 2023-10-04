-----------------------------------------------------------------------
--                                                                   --
--                             V E C T O R S                         --
--                                                                   --
--                            $Revision: 1.0 $                       --
--                                                                   --
--  Copyright (C) 2023  Hyper Quantum Pty Ltd.                       --
--  Written by Ross Summerfield.                                     --
--                                                                   --
--  This  package  provides  a type point and  a  type  vector  and  --
--  operations on points and vectors.                                --
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

with Ada.Finalization;  -- , Unchecked_Deallocation;
use  Ada.Finalization;
package Vectors is

   subtype angle is float range 0.0 .. 360.0; -- degrees
   type point is new Controlled with private;
   function origin return point;
   
   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   procedure Initialize (the_point : in out point);
   procedure Initialise (the_point : in out point) renames Initialize;
   procedure Initialise (the_point : in out point; with_x, and_y : in float;
                         and_z : in float := 0.0);
   procedure Finalize ( the_point : in out point );
   function Make_Point(at_x, at_y : in float; 
                       at_z : in float := 0.0) return point;
   
   function X(for_point : in point) return float;
   function Y(for_point : in point) return float;
   function Z(for_point : in point) return float;
   procedure Set_X(for_point : in out point; to : in float);
   procedure Set_Y(for_point : in out point; to : in float);
   procedure Set_Z(for_point : in out point; to : in float);
   function Scale(the_point : in point; by : in float) return point;
   function "+"(of_point, and_point : in point) return point;
   function "+"(of_point : in point; with_value : in float) return point;
   function "-"(from_point, the_point : in point) return point;
   function "-"(from_point : in point; the_value : in float) return point;
   function "-"(of_the_point : in point) return point; -- unary operator
   function "*"(the_point : in point; by : in point) return point;
   function "*"(the_point : in point; by : in float) return point
   renames Scale;
   function "/"(the_point : in point; by : in float) return point;
   
   type vector is private;
   -- procedure Initialise (the_vector : in out vector);
   procedure Initialise (the_vector : in out vector; at_origin : point:=origin;
                         with_angle : angle; and_distance : float);
   procedure Initialise (the_vector : in out vector; 
                         at_start, at_end : point:= origin);
   procedure Finalise (the_vector : in out vector);
   function The_Vector(for_start, and_end : in point) return vector;
   procedure Set_Start(for_Vector : in out vector; to : in point);
   procedure Set_End  (for_Vector : in out vector; to : in point);
   function Start_Point  (for_vector : in vector) return point;
   function End_Point    (for_vector : in vector) return point;
   function Recentre(the_vector : in vector) return vector;
      -- Move the vector such that its origin is (0,0,0)
   type planes is (x_y, x_z, y_z);
   function Direction (for_vector : in vector; for_plane : planes := x_y)
    return angle;
      -- returns the angle in degrees (not radians!)
      -- Currently only returns for a 2-dimension vector angle in one of
      -- the planes, being either X-Y plane, X-Z plane or the Y-Z plane.
   function Angle_Between(first_vector, and_second_vector : vector) 
    return angle;
   function Magnitude (for_vector : in vector) return float;
   function Normalise(the_vector : in vector) return vector;
      -- Set the origin of the resultant vector to zero with the end point being
      -- set to the normalised end points
   procedure Normalise(the_vector : out vector; against_vector : in vector; 
                       mag : out float);
      -- Set the origin of the resultant vector to zero with the end point being
      -- set to the normalised end points and also provide back the magnitude
   function Scale(the_vector : in vector; by : in float) return vector;
   function Dot_Product(for_vector, with_vector : in vector) return float;
   function "*" (for_vector, with_vector : in vector) return float 
   renames Dot_Product;
   function Cross_Product(for_vector, with_vector : in vector) return vector;
   function "*" (for_vector, with_vector : in vector) return vector 
   renames Cross_Product;
   function Cross_Product_Mag(for_vector, with_vector : in vector) return float;
      -- The anti-commutative magnitude of the cross product
   function Vector_Sum(of_vector, and_vector : in vector) return vector;
   function "+" (of_vector, and_vector : in vector) return vector
   renames Vector_Sum;
   function Vector_Subtract(from_vector, the_vector : in vector) return vector;
   function "-" (from_vector, the_vector : in vector) return vector
   renames Vector_Subtract;
   function "+"(of_vector : in vector; and_point : in point) return vector;
      -- offset the vector by the coordinates of the point.
   function Vector_Tip_Distance(from_vector_tip, to_vector_tip : in vector)
   return float;
      -- Measure the Euclidean distance between the end points of two vectors.
      -- Note that the operation is done as Sqrt(from_vector_tip-to_vector_tip)
      -- as you might find, e.g. in Wikipedia at
      -- https://en.wikipedia.org/wiki/Euclidean_distance.
   function Vector_Start_Distance(from_vector_start,to_vector_start: in vector)
   return float;
      -- Measure the Euclidean distance between the start points of two vectors.
      -- Note that the operation is done as Sqrt(from_vector_tip-to_vector_tip)
      -- as you might find, e.g. in Wikipedia at
      -- https://en.wikipedia.org/wiki/Euclidean_distance.
   
   private
   
   type point is new controlled with record
         x, y, z : float;
      end record;
      
   type vector is record
         point_a, point_b : point;
      end record;
   
end Vectors;