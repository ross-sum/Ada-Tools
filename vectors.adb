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

-- with Ada.Finalization;  -- , Unchecked_Deallocation;
-- use  Ada.Finalization;
with Error_Log;
with Ada.Numerics.Generic_Elementary_Functions;
package body Vectors is

   package Float_Trig is new Ada.Numerics.Generic_Elementary_Functions(float);
   
   -- subtype angle is float range 0.0 .. 360.0; -- degrees
   -- type point is new Controlled with private;
   -- origin : constant point;
   
   -- Initialisation and finalisation is exposed here so that
   -- descendent components can call the inherited operation
   -- as a part of their initialisation and finalisation.
   
   procedure Initialize (the_point : in out point ) is
   begin
      -- Initialise, setting the origin to (0,0,0)
      the_point.x := 0.0;
      the_point.y := 0.0;
      the_point.z := 0.0;
   end Initialize;
   
   procedure Initialise (the_point : in out point; with_x, and_y : in float;
                         and_z : in float := 0.0) is
   begin
      the_point.x := with_x;
      the_point.y := and_y;
      the_point.z := and_z;
   end Initialise;
   
   procedure Finalize ( the_point : in out point ) is
   begin
      null; -- nothing to do here
   end Finalize;
   
   function Make_Point(at_x, at_y : in float; 
                       at_z : in float := 0.0) return point is
      the_point : point;
   begin
      Initialise(the_point, with_x => at_x, and_y => at_y, and_z => at_z);
      return the_point;
   end Make_Point;
   
   function X(for_point : in point) return float is
   begin
      return for_point.x;
   end X;
   
   function Y(for_point : in point) return float is
   begin
      return for_point.y;
   end Y;
   
   function Z(for_point : in point) return float is
   begin
      return for_point.z;
   end Z;

   procedure Set_X(for_point : in out point; to : in float) is
   begin
      for_point.x := to;
   end Set_X;
   
   procedure Set_Y(for_point : in out point; to : in float) is
   begin
      for_point.y := to;
   end Set_Y;
   
   procedure Set_Z(for_point : in out point; to : in float) is
   begin
      for_point.z := to;
   end Set_Z;
   
   function origin return point is
      o : point;
   begin
      o.x := 0.0;
      o.y := 0.0;
      o.z := 0.0;
      return o;
   end origin;
   
   function Scale(the_point : in point; by : in float) return point is
      result : point;
   begin
      result.x := the_point.x * by;
      result.y := the_point.y * by;
      result.z := the_point.z * by;
      return result;
   end Scale;

   function "*"(the_point : in point; by : in point) return point is
      result : point;
   begin
      result.x := the_point.x * by.x;
      result.y := the_point.y * by.y;
      result.z := the_point.z * by.z;
      return result;
   end "*";
   
   function "/"(the_point : in point; by : in float) return point is
      result : point;
      -- Scale by division
   begin
      result.x := the_point.x / by;
      result.y := the_point.y / by;
      result.z := the_point.z / by;
      return result;
   end "/";

   function "+"(of_point, and_point : in point) return point is
      result : point;
   begin
      result.x := of_point.x + and_point.x;
      result.y := of_point.y + and_point.y;
      result.z := of_point.z + and_point.z;
      return result;
   end "+";
   
   function "+"(of_point : in point; with_value : in float) return point is
      result : point;
   begin
      result.x := of_point.x + with_value;
      result.y := of_point.y + with_value;
      result.z := of_point.z + with_value;
      return result;
   end "+";
   
   function "-"(from_point, the_point : in point) return point is
      result : point;
   begin
      result.x := from_point.x - the_point.x;
      result.y := from_point.y - the_point.y;
      result.z := from_point.z - the_point.z;
      return result;
   end "-";
   
   function "-"(from_point : in point; the_value : in float) return point is
      result : point;
   begin
      result.x := from_point.x - the_value;
      result.y := from_point.y - the_value;
      result.z := from_point.z - the_value;
      return result;
   end "-";
  
   function "-"(of_the_point : in point) return point is -- unary operator
      result : point;
   begin
      result.x := of_the_point.x;
      result.y := of_the_point.y;
      result.z := of_the_point.z;
      return result;
   end "-";
     
   -- type vector is private;
   -- procedure Initialise (the_vector : in out vector) is
   -- begin
      -- the_vector.point_a := origin;
      -- the_vector.point_b := origin;
   -- end Initialise;
   
   procedure Initialise (the_vector : in out vector; at_origin : point:=origin; 
                         with_angle : angle; and_distance : float) is
      use Float_Trig;
   begin
      the_vector.point_a := at_origin;
      the_vector.point_b.x := at_origin.x + and_distance/cos(with_angle,360.0);
      the_vector.point_b.y := at_origin.y + and_distance/sin(with_angle,360.0);
   end Initialise;
   
   procedure Initialise (the_vector : in out vector; 
                         at_start, at_end : point:= origin) is
   begin
      the_vector.point_a := at_start;
      the_vector.point_b := at_end;
   end Initialise;
   
   procedure Finalise (the_vector : in out vector) is
   begin
      null;  -- nothing to do here
   end Finalise;
   
   function The_Vector(for_start, and_end : in point) return vector is
      result : vector;
   begin
      Initialise(the_vector=> result, at_start=> for_start, at_end=> and_end);
      return result;
   end The_Vector;
   
   function Recentre(the_vector : in vector) return vector is
      -- Move the vector such that its origin is (0,0,0)
      result : vector;
   begin
      Initialise(the_Vector => result, at_end =>
                 Make_Point(at_x=>(the_vector.point_b.x-the_vector.point_a.x),
                            at_y=>(the_vector.point_b.y-the_vector.point_a.y),
                            at_z=>(the_vector.point_b.z-the_vector.point_a.z)));
   
      return result;
   end Recentre;
   
   -- type planes is (x_y, x_z, y_z);
   function Direction (for_vector : in vector; for_plane : planes := x_y)
    return angle is
      use Float_Trig;
      the_angle : angle;
      offset : angle := 0.0;
      point_a_1,
      point_a_2,
      point_b_1,
      point_b_2 : float;
   begin
      -- set up the points for the appropriate plane
      case for_plane is
         when x_y => 
            point_a_1:= for_vector.point_a.x; point_a_2:= for_vector.point_a.y;
            point_b_1:= for_vector.point_b.x; point_b_2:= for_vector.point_b.y;
         when x_z =>
            point_a_1:= for_vector.point_a.x; point_a_2:= for_vector.point_a.z;
            point_b_1:= for_vector.point_b.x; point_b_2:= for_vector.point_b.z;
         when y_z =>
            point_a_1:= for_vector.point_a.y; point_a_2:= for_vector.point_a.z;
            point_b_1:= for_vector.point_b.y; point_b_2:= for_vector.point_b.z;
      end case;
      if (point_b_2 - point_a_2) < 0.0
      then  -- y is negative (i.e. quadrant III or IV)
         if (point_b_1 - point_a_1) < 0.0
         then  -- x is negative (i.e. quadrant (II or III)
            offset := 180.0;  -- Quadrant III
         else  -- x is positive (i.e. quadrant I or IV)
            offset := 270.0;  -- Quadrant IV
         end if;
      else  -- y is positive (i.e. quadrant I or II)
         if (point_b_1 - point_a_1) < 0.0
         then  -- x is negative (i.e. quadrant (II or III)
            offset := 90.0;  -- Quadrant II
         -- else  -- x is positive (i.e. quadrant I or IV)
         --   offset := .0;  -- Quadrant I
         end if;
      end if;
      if point_b_2 = point_a_2
      then  -- 'horizontal' line
         the_angle := 0.0;  -- define
      elsif point_b_1 = point_a_1
      then  -- 'vertical' line
         the_angle := 90.0;  -- define, otherwise numeric error
      else  -- calculate it from arctan(opp/adj)
         the_angle := ArcTan(y => abs(point_b_2 - point_a_2),
                             x => abs(point_b_1 - point_a_1),
                             Cycle=> 360.0);
      end if;
      if offset = 0.0 or offset = 180.0
      then  -- Quadrant I or III
         return the_angle + offset;
      else  -- Quadrant II or IV
         return 90.0 - the_angle + offset;
      end if;
   end Direction;
   
   function Angle_Between(first_vector, and_second_vector : vector) 
    return angle is
      use Float_Trig;
      -- Recasted vectors, resetting the origin for each vector to (0,0,0)
      first     : vector := Recentre(the_vector => first_vector);
      second    : vector := Recentre(the_vector => and_second_vector);
      mag_a,
      mag_b     : float;
      a_x_b     : vector;
      mag_axb   : float;
      sin_theta : float;
   begin
      -- get the magnitude of each vector
      mag_a := Magnitude(for_vector => first);
      mag_b := Magnitude(for_vector => second);
      -- Get the cross product of the two vectors
      a_x_b := Cross_Product(for_vector => first, with_vector => second);
      -- Get the magnitude of the cross product
      mag_axb := Magnitude(for_vector => a_x_b);
      -- Noting that a x b = |a||b|sin(theta), so theta =arcsin((a x b)/|a|}b|)
      sin_theta := mag_axb / (mag_a * mag_b);
      return Angle(arcsin(sin_theta, 360.0));
   end Angle_Between;

   function Magnitude (for_vector : in vector) return float is
      use Float_Trig;
      the_distance : float;
   begin
      the_distance:=Sqrt((abs(for_vector.point_b.x-for_vector.point_a.x))**2.0+
                         (abs(for_vector.point_b.y-for_vector.point_a.y))**2.0+
                         (abs(for_vector.point_b.z-for_vector.point_a.z))**2.0);
      return the_distance;
   end Magnitude;
   
   procedure Set_Start(for_Vector : in out vector; to : in point) is
   begin
      for_vector.point_a := to;
   end Set_Start;
   
   function Normalise(the_vector : in vector) return vector is
      mag       : float := Magnitude(for_vector => the_vector);
      result    : vector;
   begin
      if mag /= 0.0
      then
         -- Set the origin of the resultant vector to zero with the end point being
         -- set to the normalised end points
         Initialise(the_vector => result,
                    at_end => 
                     Make_Point(at_x=>(the_vector.point_b.x-the_vector.point_a.x)/mag,
                                at_y=>(the_vector.point_b.y-the_vector.point_a.y)/mag,
                                at_z=>(the_vector.point_b.z-the_vector.point_a.z)/mag));
      else  -- The vector is zero length (a single point), so set it at the origin.
         Initialise(the_vector => result, at_end => origin);
      end if;
      return result;
   end Normalise;

   procedure Normalise(the_vector : out vector; against_vector : in vector; 
                       mag : out float) is
      -- Set the origin of the resultant vector to zero with the end point being
      -- set to the normalised end points and also provide back the magnitude
   begin
      mag := Magnitude(for_vector => against_vector);
      the_vector := Normalise(the_vector => against_vector);
   end Normalise;

   function Scale(the_vector : in vector; by : in float) return vector is
      result : vector;
   begin
      result.point_a := Scale(the_vector.point_a, by);
      result.point_b := Scale(the_vector.point_b, by);
      return result;
   end Scale;

   function Dot_Product(for_vector, with_vector : in vector) return float is
      -- The dot product of two vectors is the magnitude of each vector multiplied
      -- together times the cosine of the angle between them, or |a||b|cos(t) where
      -- a is vector a and b is vector b, |a| is the magitude of a and t is the angle
      -- between the twor vectors.
      -- Note that the dot product can also be calculated as x1 * x2 + y1 * y2,
      -- where for_vector =(x1, y1) and with_vector = (x2, y2), assuming that 
      -- those points are the second point of the vector and that the vector 
      -- has been recentred such that its first point is (0, 0).
      use Float_Trig;
      mag_a : float := Magnitude(for_vector);
      mag_b : float := Magnitude(with_vector);
      ang_ab: float := abs(Direction(with_vector) - Direction(for_vector));
      cos_ab: float;
   begin
      -- Calculate the cosine, noting that Float_Trig will only do between
      -- 0 and 90 degrees correctly
      if ang_ab <= 90.0 then
         cos_ab := Cos(ang_ab, 360.0);
      elsif ang_ab <= 180.0 then
         cos_ab := -Cos(180.0 - ang_ab, 360.0);
      elsif ang_ab <= 270.0 then
         cos_ab := -Cos(ang_ab - 180.0, 360.0);
      else -- ang_ab <= 360.0
         cos_ab := Cos(360.0 - ang_ab, 360.0);
      end if;
      -- Now compute the dot product between the two end points
      return mag_a * mag_b * cos_ab;
   end Dot_Product;
   
   function Cross_Product(for_vector, with_vector : in vector) return vector is
      use Float_Trig;
      point_a,
      point_b : point;
      result  : vector;
   begin
      -- In cross product, the angle is between 0 and 180 degrees.
      -- For just 2 dimensions:
      --   Calculate using the (right-hand rule) angle n, which is
      --   perpendicular to
      --   then cow calculate the result as |a| . |b| . sin(ang_ab) . n
      --   (for a pair of 2 dimensional vectors in the X-Y plane)
      -- For 3 dimensions, r=i|ay*bz-az*by|-j|ax*bz-az*bx|+k|ax*by-ay*bx|
      -- Re-centre the points back to the origin (0,0)
      Initialise(point_a, 
                 with_x => (for_vector.point_b.x - for_vector.point_a.x),
                 and_y  => (for_vector.point_b.y - for_vector.point_a.y),
                 and_z  => (for_vector.point_b.z - for_vector.point_a.z));
      Initialise(point_b, 
                 with_x => (with_vector.point_b.x - with_vector.point_a.x),
                 and_y  => (with_vector.point_b.y - with_vector.point_a.y),
                 and_z  => (with_vector.point_b.z - with_vector.point_a.z));
      Set_End(for_Vector => result, 
              to => Make_Point(+abs(point_a.y*point_b.z-point_a.z*point_b.y), 
                               -abs(point_a.x*point_b.z-point_a.z*point_b.x), 
                               +abs(point_a.x*point_b.y-point_a.y*point_b.x)));
      return result;
   end Cross_Product;

   function Cross_Product_Mag(for_vector, with_vector : in vector) return float is
      -- The magnitude of the cross product
      point_a,
      point_b : point;
   begin
      -- Re-centre the points back to the origin (0,0)
      Initialise(point_a, 
                 with_x => (for_vector.point_b.x - for_vector.point_a.x),
                 and_y  => (for_vector.point_b.y - for_vector.point_a.y),
                 and_z  => (for_vector.point_b.z - for_vector.point_a.z));
      Initialise(point_b, 
                 with_x => (with_vector.point_b.x - with_vector.point_a.x),
                 and_y  => (with_vector.point_b.y - with_vector.point_a.y),
                 and_z  => (with_vector.point_b.z - with_vector.point_a.z));
      -- Calculate the magnitude for the X-Y plane, knowing that both points
      -- are centred at the origin.
      return point_a.y * point_b.x - point_b.y * point_a.x;
   end Cross_Product_Mag;
   
   procedure Set_End  (for_Vector : in out vector; to : in point) is
   begin
      for_vector.point_b := to;
   end Set_End;
   
   function Start_Point  (for_vector : in vector) return point is
   begin
      return for_vector.point_a;
   end Start_Point;
   
   function End_Point    (for_vector : in vector) return point is
   begin
      return for_vector.point_b;
   end End_Point;

   function Vector_Sum(of_vector, and_vector : in vector) return vector is
      result : vector;
   begin
      result.point_a.x := of_vector.point_a.x + and_vector.point_a.x;
      result.point_a.y := of_vector.point_a.y + and_vector.point_a.y;
      result.point_a.z := of_vector.point_a.z + and_vector.point_a.z;
      result.point_b.x := of_vector.point_b.x + and_vector.point_b.x;
      result.point_b.y := of_vector.point_b.y + and_vector.point_b.y;
      result.point_b.z := of_vector.point_b.z + and_vector.point_b.z;
      return result;
   end Vector_Sum;
    
   function Vector_Subtract(from_vector, the_vector : in vector) return vector
   is
      result : vector;
   begin
      result.point_a.x := from_vector.point_a.x - the_vector.point_a.x;
      result.point_a.y := from_vector.point_a.y - the_vector.point_a.y;
      result.point_a.z := from_vector.point_a.z - the_vector.point_a.z;
      result.point_b.x := from_vector.point_b.x - the_vector.point_b.x;
      result.point_b.y := from_vector.point_b.y - the_vector.point_b.y;
      result.point_b.z := from_vector.point_b.z - the_vector.point_b.z;
      return result;
   end Vector_Subtract;

   function "+"(of_vector : in vector; and_point : in point) return vector is
      -- offset the vector by the coordinates of the point.
      result : vector;
   begin
      result.point_a.x := of_vector.point_a.x + and_point.x;
      result.point_a.y := of_vector.point_a.y + and_point.y;
      result.point_a.z := of_vector.point_a.z + and_point.z;
      result.point_b.x := of_vector.point_b.x + and_point.x;
      result.point_b.y := of_vector.point_b.y + and_point.y;
      result.point_b.z := of_vector.point_b.z + and_point.z;
      return result;
   end "+";

   function Vector_Tip_Distance(from_vector_tip, to_vector_tip : in vector)
   return float is
      -- Measure the Euclidean distance between the end points of two vectors.
      -- This calculation does not reset the origin of the vectors.  If that is
      -- required, then it needs to be done as a separate step.
      -- It works in 3 dimensional space.  If 2 dimensions only are required,
      -- then that is the same as setting one of the dimension's plane (e.g.
      -- the 'Z' plane) to 0 as in at point (a, b, 0) where a and b are the x
      -- and y values of the vector end point.
      -- The end point is the second point in the vector.
      use Float_Trig;
      p1 : point renames from_vector_tip.point_b;
      p2 : point renames to_vector_tip.point_b;
   begin      
      return Sqrt((p1.x - p2.x)**2.0 + (p1.y - p2.y)**2.0 + (p1.z - p2.z)**2.0);
   end Vector_Tip_Distance;

   function Vector_Start_Distance(from_vector_start,to_vector_start: in vector)
   return float is
      -- Measure the Euclidean distance between the start points of two vectors.
      -- Note that the operation is done as Sqrt(from_vector_tip-to_vector_tip)
      -- as you might find, e.g. in Wikipedia at
      -- https://en.wikipedia.org/wiki/Euclidean_distance.
      -- Comments relating to Vector_Tip_Distance generally apply here.
      use Float_Trig;
      p1 : point renames from_vector_start.point_a;
      p2 : point renames to_vector_start.point_a;
   begin      
      return Sqrt((p1.x - p2.x)**2.0 + (p1.y - p2.y)**2.0 + (p1.z - p2.z)**2.0);
   end Vector_Start_Distance;
   
--    private
--    
--    type point is new controlled with record
--          x, y : float;
--       end record;
--    
--    origin : constant point := (0.0, 0.0);
--    
--    type vector is new Controlled with record
--          point_a, point_b : point;
--       end record;
   
end Vectors;