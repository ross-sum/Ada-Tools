-- This program tests the operation of the Vectors package to ensure that
-- it calculates correctly.

with Vectors;      use Vectors;
with Ada.Text_IO;  use Ada.Text_IO;
with Ada.Float_Text_IO;

procedure Test_Vectors is

   function Img(val : in float) return string is
      use Ada.Float_Text_IO;
      result : string(1..7);
   begin
      Put(to => result, item => val, aft => 3, exp => 0);
      return result;
   end Img;
   procedure Pass_Fail(ans1, val1, ans2, val2 : in float) is
   begin
      if abs(ans1-val1) < 0.0001 and abs(ans2-val2)<0.01
      then
         Put_Line(">>> Pass");
      else
         Put_Line(">>> ***Fail***");
      end if;
   end Pass_Fail;
   
   procedure Test_Mag_and_Dir (point_1, point_2 : in point; quadrant : in positive; ans1, ans2 : in float) is
      a_vector : vector;
   begin
      Put("Quadrant" & quadrant'Image);
      Initialise (a_vector, at_start => point_1, at_end => point_2);
      Put(" For p1=(" & 
          Img(X(for_point => point_1)) & "," &
          Img(Y(for_point => point_1)) & "," &
          Img(Z(for_point => point_1)) & "), p2=(" &
          Img(X(for_point => point_2)) & "," &
          Img(Y(for_point => point_2)) & "," &
          Img(Z(for_point => point_2)) & "), angle=" &
          Img(Direction(a_vector)) & ", magnitude=" &
          Img(Magnitude(a_vector)) & ".  ");
      Pass_Fail(Magnitude(a_vector), ans1, Direction(a_vector), ans2);
   end Test_Mag_and_Dir;
   
   procedure Test_Magnitude_And_Direction(point_1, point_2 : in point; ans1, ans2, ans3, ans4 : in float) is
      mag        : float;
      dir        : float;
      point_3    : point;
   begin
      mag := Magnitude(The_Vector(for_start => point_1, and_end => point_2));
      point_3 := (point_1 + point_2)*(mag / 2.0);
      dir := Direction(The_Vector(point_1,point_2));
      Put("For p1=(" & Img(X(for_point => point_1)) & "," &
            Img(Y(for_point => point_1)) & "), p2=(" &
            Img(X(for_point => point_2)) & "," &
            Img(Y(for_point => point_2)) & "), vec2_mag=" &
            Img(mag) & ", vec2_angle=" &
            Img(dir) &
            ", vec2_scale=(" &
            Img(X(for_point => point_3)) & "," &
            Img(Y(for_point => point_3)) & ").");
      Pass_Fail(X(for_point=>point_3), ans1,
             Y(for_point=>point_3), ans2);
      Pass_Fail(mag, ans3, dir, ans4);
   end Test_Magnitude_And_Direction;
    
   procedure Test_Smooth_Stroke (p1, p2, p3 : in point; ans : in point) is
      function Approx_Equal(p1, p2 : in point) return boolean is
         precision : constant float := 0.0005;
      begin
         return abs(X(p1) - X(p2)) < precision and
                abs(Y(p1) - Y(p2)) < precision and
                abs(Z(p1) - Z(p2)) < precision;
      end;
      function Point_Projection(a, b : in point) return point is
         dist  : float;
         mag   : float;
         vec_a : vector := The_Vector(for_start => origin, and_end => a);
         vec_b : vector := The_Vector(for_start => origin, and_end => b);
      begin
         dist := Dot_Product(vec_a, vec_b);
         mag  := Magnitude(vec_b);
         mag := mag * mag;  -- we actually want the square of magnitude
         return b * dist / mag;
      end Point_Projection;
      result : point;
      a,
      b,
      c  : point;
   begin
      a  := p1;                        -- a = last point
      b  := p2;     -- b = this point
      c  := p3; -- c = next point
      result := b + (a + Point_Projection(b - a, c - a) - b) * 0.5 + 0.5;
      Set_Z(for_point => result, to => 0.0);  -- annul that 0.5 in the z plane
      Put("For p1=("  &
          Img(X(for_point=>p1)) & "," &
          Img(Y(for_point=>p1)) & "," &
          Img(Z(for_point=>p1)) & "), p2=(" &
          Img(X(for_point=>p2)) & "," &
          Img(Y(for_point=>p2)) & "," &
          Img(Z(for_point=>p2)) & "), p3=(" &
          Img(X(for_point=>p3)) & "," &
          Img(Y(for_point=>p3)) & "," &
          Img(Z(for_point=>p3)) & "), result=("&
          Img(X(for_point=>result)) & "," &
          Img(Y(for_point=>result)) & "," &
          Img(Z(for_point=>result)) & ").  ");
      if Approx_Equal(result, ans)
      then  Put_Line(" >>> Pass");
      else  Put_Line(" >>> ***Fail***");
      end if;
   end Test_Smooth_Stroke;

   procedure Test_Measure_Distance(p1, p2, offset : in point; ans : in float) is
      -- Measure the square of the offset Euclidean distance between two points
      function Approx_Equal(a1, a2 : in float) return boolean is
         precision : constant float := 0.0005;
      begin
         return abs(a1 - a2) < precision;
      end;
      point_a : point := p1 + offset;
      point_b : point renames p2;
      result   : float;
   begin
      result:= Magnitude(The_Vector(for_start => point_a, and_end => point_b));
      result := result * result;
      Put("For p1=("  &
          Img(X(for_point=>p1)) & "," &
          Img(Y(for_point=>p1)) & "," &
          Img(Z(for_point=>p1)) & "), p2=(" &
          Img(X(for_point=>p2)) & "," &
          Img(Y(for_point=>p2)) & "," &
          Img(Z(for_point=>p2)) & "), offset=(" &
          Img(X(for_point=>offset)) & "," &
          Img(Y(for_point=>offset)) & "," &
          Img(Z(for_point=>offset)) & "), result="&
          Img(result) & ".  ");
      if Approx_Equal(result, ans)
      then  Put_Line(" >>> Pass");
      else  Put_Line(" >>> ***Fail***");
      end if;
   end Test_Measure_Distance;
   
   procedure Test_Simplify_Stroke(p1, p2, p3 : in point; ans1, ans2, ans3 : in float) is
      function Approx_Equal(a1, a2 : in float) return boolean is
         precision : constant float := 0.0005;
      begin
         return abs(a1 - a2) < precision;
      end;
      len_vector, width_vector : vector;
      mag : float;
      dp  : float;
      dist: float;
   begin
      Initialise(the_vector => len_vector, at_start => p1, at_end => p3);
      Normalise(the_vector => len_vector, against_vector => len_vector, 
                   mag => mag);
         -- Vector width is a vector from the point at 'point_no - 1' to our
         -- point at 'point_no'
      Initialise(the_vector => width_vector, at_start => p1, at_end => p2);
         -- Do not touch mid points that are not in between their neighbours
         -- get the dot product:
      dp := len_vector * width_vector;
      dist := Magnitude(len_vector * width_vector);
      Put("For p1=("  &
          Img(X(for_point=>p1)) & "," &
          Img(Y(for_point=>p1)) & "," &
          Img(Z(for_point=>p1)) & "), p2=(" &
          Img(X(for_point=>p2)) & "," &
          Img(Y(for_point=>p2)) & "," &
          Img(Z(for_point=>p2)) & "), p3=(" &
          Img(X(for_point=>p3)) & "," &
          Img(Y(for_point=>p3)) & "," &
          Img(Z(for_point=>p3)) & "), mag="&
          Img(mag) & ", dot=" & Img(dp) & ",dist=" & Img(dist) & ".  ");
      if Approx_Equal(mag, ans1) and Approx_Equal(dp, ans2) and Approx_Equal(dist, ans3)
      then  Put_Line(" >>> Pass");
      else  Put_Line(" >>> ***Fail***");
      end if;
   end Test_Simplify_Stroke;
   
   point_1, point_2 : point;
   point_3          : point;
   ans_point        : point;
   a_vector : vector;
   norm_vector: vector;
   second_vec : vector;
   mag        : float;
   dotproduct : float;
   x_product  : float;
begin
   -- Test adding 2 points
   Initialise (the_point => point_1, with_x => 1.0, and_y => 5.0);
   Initialise (the_point => point_2, with_x => 3.0, and_y => 2.0);
   point_3 := point_1 + point_2;
   Put_Line("For point 1=("  &
            Img(X(for_point=>point_1)) & "," &
            Img(Y(for_point=>point_1)) & "," &
            Img(Z(for_point=>point_1)) & ") + point 2 (" &
            Img(X(for_point=>point_2)) & "," &
            Img(Y(for_point=>point_2)) & "," &
            Img(Z(for_point=>point_2)) & "), the summed point=(" &
            Img(X(for_point=>point_3)) & "," &
            Img(Y(for_point=>point_3)) & "," &
            Img(Z(for_point=>point_3)) & ").");
   Pass_Fail(X(for_point=>point_3), X(for_point=>point_1) + X(for_point=>point_2),
             Y(for_point=>point_3), Y(for_point=>point_1) + Y(for_point=>point_2));
   -- Test first quadrant
   Put_Line("Magnitude + direction tests:\n");
   Initialise(the_point => point_1);  -- initialise and set to origin (0,0)
   Initialise (the_point => point_2, with_x => 3.0, and_y => 2.0);
   Test_Mag_and_Dir (point_1, point_2, quadrant=> 1, ans1=>3.6055, ans2=>33.69);
   -- Test second quadrant
   Initialise (the_point => point_2, with_x => -4.0, and_y => 3.0);
   Test_Mag_and_Dir (point_1, point_2, quadrant=> 2, ans1=>5.0, ans2=>143.130);
   -- Test third quadrant
   Initialise (the_point => point_2, with_x => -3.0, and_y => -3.0);
   Test_Mag_and_Dir (point_1, point_2, quadrant=> 3, ans1=>4.2426, ans2=>225.0);
   -- Test fourth quadrant
   Initialise (the_point => point_2, with_x => 4.0, and_y => -4.0);
   Test_Mag_and_Dir (point_1, point_2, quadrant=> 4, ans1=>5.656854, ans2=>315.0);
   -- Test a non-zero origin for first quadrant
   Initialise(the_point => point_1, with_x => 2.0, and_y => 2.0);
   Initialise (the_point => point_2, with_x => 5.0, and_y => 4.0);
   Test_Mag_and_Dir (point_1, point_2, quadrant=> 1, ans1=>3.6055, ans2=>33.69);
   -- Test Normalised vector calculation
   Initialise (a_vector, at_start => point_1, at_end => point_2);
   norm_vector := Normalise(a_vector);
   Put_Line("For the same points, the Normalised point is (" &
            Img(X(for_point=>End_Point(for_vector=>norm_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>norm_vector))) & ").");
   Pass_Fail(X(End_Point(norm_vector)), 0.83205, Y(End_Point(norm_vector)), 0.55470);
   -- Test Dot Product calculation of two vectors, using P5 (= P1 + offset of
   -- (2,2) and P2
   Initialise(the_point => point_1);  -- initialise and set to origin (0,0)
   Initialise (the_point => point_2, with_x => -4.0, and_y => 3.0);
   Initialise (second_vec, at_start => point_1, at_end => point_2);
   Put_Line("For vector 1=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & ") and vector 2=(" &
            Img(X(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>second_vec))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>second_vec))) & "), the dot product is "&
            Img(Dot_Product(a_vector, second_vec)) & ", or using the '*' approach, "&
       Img(a_vector * second_Vec) & ".");
   Pass_Fail(Dot_Product(a_vector, second_vec), -6.0, 0.0, 0.0);
   -- Test Cross Product calculation of two vectors, using P5 (= P1 + offset of
   -- (2,2) and P2
   Put_Line("For vector 1=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & ") and vector 2=(" &
            Img(X(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>second_vec))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>second_vec))) & "), the Magnitude (cross product) is "&
            Img(Magnitude(Cross_Product(a_vector, second_vec))) & " and the cross product magnitude is "&
            Img(Cross_Product_Mag(a_vector, second_vec)) & ".");
   Pass_Fail(Magnitude(Cross_Product(a_vector, second_vec)), 17.0, 
             Cross_Product_Mag(a_vector, second_vec), -17.0);
   -- Test Scaling of a vector
   Initialise(the_point => point_1);  -- initialise and set to origin (0,0)
   Initialise (the_point => point_2, with_x => 3.0, and_y => 2.0);
   Initialise (a_vector, at_start => point_1, at_end => point_2);
   a_vector := Scale(the_vector => a_vector, by => 2.0);
   Put_Line("For vector 1=(" &
            Img(X(for_point=>point_1)) & "," &
            Img(Y(for_point=>point_1)) & "," &
            Img(Z(for_point=>point_1)) & ") to (" &
            Img(X(for_point=>point_2)) & "," &
            Img(Y(for_point=>point_2)) & "," &
            Img(Z(for_point=>point_2)) & "), the scaled vector=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>a_vector))) & ").");
   Pass_Fail(X(for_point=>End_Point(for_vector=>a_vector)), 2.0 * X(for_point=>point_2),
             Y(for_point=>End_Point(for_vector=>a_vector)), 2.0 * Y(for_point=>point_2));
   -- Test Scaling of a point
   point_3 := point_2 * 2.0;
   Put_Line("For point 2=(" &
            Img(X(for_point=>point_2)) & "," &
            Img(Y(for_point=>point_2)) & "," &
            Img(Z(for_point=>point_2)) & "), the scaled point=(" &
            Img(X(for_point=>point_3)) & "," &
            Img(Y(for_point=>point_3)) & "," &
            Img(Z(for_point=>point_3)) & ").");
   Pass_Fail(X(for_point=>point_3), 2.0 * X(for_point=>point_2),
             Y(for_point=>point_3), 2.0 * Y(for_point=>point_2));
   -- Test Angle_Between two vectors (in 3-dimensional space)
   Initialise(the_point => point_1);  -- initialise and set to origin (0,0)
   Initialise (the_point => point_2, with_x => 2.0, and_y => -4.0, and_z => 4.0);
   Initialise (a_vector, at_start => point_1, at_end => point_2);
   Initialise (the_point => point_2, with_x => 4.0, and_y => 0.0, and_z => 3.0);
   Initialise (second_vec, at_start => point_1, at_end => point_2);
   Put_Line("For vector 1=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>a_vector))) & ") and vector 2=(" &
            Img(X(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>second_vec))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>second_vec))) & "), the angle between them is "&
            Img(Angle_Between(first_vector=>a_vector, and_second_vector=>second_vec)) & ".");
   Pass_Fail(Angle_Between(a_vector, second_vec), 48.189685, 0.0, 0.0);
   -- Test Vector addition
   Put_Line("For vector 1=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>a_vector))) & ") and vector 2=(" &
            Img(X(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>second_vec))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>second_vec))) & "), the sum of them is ("&
            Img(X(for_point=>End_Point(a_vector + second_vec))) & "," &
            Img(Y(for_point=>End_Point(a_vector + second_vec))) & "," &
            Img(Z(for_point=>End_Point(a_vector + second_vec))) & ").");
   Pass_Fail(X(for_point=>End_Point(a_vector + second_vec)), 6.0,
             Y(for_point=>End_Point(a_vector + second_vec)), -4.0);
   -- Test Vector subtraction
   Put_Line("For vector 1=(" &
            Img(X(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>a_vector))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>a_vector))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>a_vector))) & ") and vector 2=(" &
            Img(X(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>Start_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>Start_Point(for_vector=>second_vec))) & ") to (" &
            Img(X(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Y(for_point=>End_Point(for_vector=>second_vec))) & "," &
            Img(Z(for_point=>End_Point(for_vector=>second_vec))) & "), the difference between them is ("&
            Img(X(for_point=>End_Point(a_vector - second_vec))) & "," &
            Img(Y(for_point=>End_Point(a_vector - second_vec))) & "," &
            Img(Z(for_point=>End_Point(a_vector - second_vec))) & ").");
   Pass_Fail(X(for_point=>End_Point(a_vector - second_vec)), -2.0,
             Y(for_point=>End_Point(a_vector - second_vec)), -4.0);
   -- Test composite vector operation for strokes:
   Put_Line("Testing composite vector operation for Michael Levan's strokes:");
   -- using (0,0) and (0,0):
   Initialise(the_point => point_1, with_x => 0.0, and_y => 0.0);
   Initialise(the_point => point_2, with_x => 0.0, and_y => 0.0);
   Test_Magnitude_And_Direction(point_1, point_2, ans1 => 0.0, ans2 => 0.0, ans3 => 0.0, ans4 => 0.0);
   -- using (0,0) and (1,1):
   Initialise(point_1, with_x => 0.0, and_y => 0.0);
   Initialise(point_2, with_x => 1.0, and_y => 1.0);
   Test_Magnitude_And_Direction(point_1, point_2, 
                                ans1 => 0.707106781186548, ans2 => 0.707106781186548, 
                                ans3 => 1.4142135623731, ans4 => 45.0);
   mag := Magnitude(The_Vector(for_start => point_1, and_end => point_2));
   -- using (1,1) and (1,1):
   Initialise(point_1, with_x => 1.0, and_y => 1.0);
   Initialise(point_2, with_x => 1.0, and_y => 1.0);
   Test_Magnitude_And_Direction(point_1, point_2, ans1 => 0.0, ans2 => 0.0, ans3 => 0.0, ans4 => 0.0);
   -- using (5,5) and (10,10):
   Initialise(point_1, with_x => 5.0, and_y => 5.0);
   Initialise(point_2, with_x => 10.0, and_y => 10.0);
   Test_Magnitude_And_Direction(point_1, point_2, 
                                ans1 => 53.0330085889911, ans2 => 53.0330085889911, 
                                ans3 => 7.07106781186548, ans4 => 45.0);
   -- using (1,5) and (7,10):
   Initialise(point_1, with_x => 1.0, and_y => 5.0);
   Initialise(point_2, with_x => 7.0, and_y => 10.0);
   Test_Magnitude_And_Direction(point_1, point_2, 
                                ans1 => 31.2409987036266, ans2 => 58.5768725692999, 
                                ans3 => 7.81024967590665, ans4 => 39.803);
   
   -- Test Process Gluable
   -- First, Normalise:
   Initialise(point_1, 1.0, 7.0);
   Initialise(point_2, 5.0, 10.0);
   Initialise(a_vector, at_start=> point_1, at_end  => point_2);
   Normalise(norm_vector, a_vector, mag);
   Put_Line("For point 1=(" & Img(X(for_point => point_1)) & "," &
            Img(Y(for_point => point_1)) & ") and point 2=(" &
            Img(X(for_point => point_2)) & "," &
            Img(Y(for_point => point_2)) & "), mag is " &
            Img(mag) &
            ", vec2_norm is (" &
            Img(X(for_point => Start_Point(norm_vector))) & "," &
            Img(Y(for_point => Start_Point(norm_vector))) & ") -> (" & 
            Img(X(for_point => End_Point(norm_vector))) & "," &
            Img(Y(for_point => End_Point(norm_vector))) & ").");
   Pass_Fail(mag, 5.00,  0.0, 0.0);
   Pass_Fail(X(for_point=>End_Point(norm_vector)), 0.800,
             Y(for_point=>End_Point(norm_vector)), 0.600);
   -- Second, dot product of norm_vector and another vector
   Initialise (the_point => point_3, with_x => -4.0, and_y => 3.0);
   Initialise(a_vector, at_start=> origin, at_end  => point_3);
   dotproduct := norm_vector * a_vector;
   x_product  := Cross_Product_Mag(norm_vector, a_vector);
   Put_Line("For vectors (" &
            Img(X(for_point => Start_Point(norm_vector))) & "," &
            Img(Y(for_point => Start_Point(norm_vector))) & ") -> (" & 
            Img(X(for_point => End_Point(norm_vector))) & "," &
            Img(Y(for_point => End_Point(norm_vector))) & ") and (" &
            Img(X(for_point => Start_Point(a_vector))) & "," &
            Img(Y(for_point => Start_Point(a_vector))) & ") -> (" & 
            Img(X(for_point => End_Point(a_vector))) & "," &
            Img(Y(for_point => End_Point(a_vector))) & 
            ") dot product is " & Img(dotproduct)& 
            " and mag cross product is " & Img(x_product) &
            " (calculated  magnitude of x product is " &
            Img(Magnitude(norm_vector * a_vector)) & ").");
   Pass_Fail(dotproduct, -1.400,  x_product, -4.800);
   
   -- Third Normalise, with points in reverse (i.e. negative)
   Initialise(a_vector, at_start=> point_2, at_end  => point_1);
   Normalise(norm_vector, a_vector, mag);
   Put_Line("For point 1=(" & Img(X(for_point => point_1)) & "," &
            Img(Y(for_point => point_1)) & ") and point 2=(" &
            Img(X(for_point => point_2)) & "," &
            Img(Y(for_point => point_2)) & "), mag is " &
            Img(mag) &
            ", vec2_norm is (" &
            Img(X(for_point => Start_Point(norm_vector))) & "," &
            Img(Y(for_point => Start_Point(norm_vector))) & ") -> (" & 
            Img(X(for_point => End_Point(norm_vector))) & "," &
            Img(Y(for_point => End_Point(norm_vector))) & ").");
   Pass_Fail(mag, 5.00,  0.0, 0.0);
   Pass_Fail(X(for_point=>End_Point(norm_vector)), -0.800,
             Y(for_point=>End_Point(norm_vector)), -0.600);
   
   Put_Line("Testing Stroke smoothing:");
   Initialise (the_point => point_1, with_x => 0.0, and_y => 0.0);
   Initialise (the_point => point_2, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_3, with_x => 2.0, and_y => 2.0);
   Initialise (the_point => ans_point, with_x => 1.500, and_y => 1.500);
   Test_Smooth_Stroke (p1 => point_1, p2 => point_2, p3 => Point_3, ans => ans_point);
   Initialise (the_point => point_1, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_2, with_x => 2.0, and_y => 2.0);
   Initialise (the_point => point_3, with_x => 3.0, and_y => 3.0);
   Initialise (the_point => ans_point, with_x => 2.500, and_y => 2.500);
   Test_Smooth_Stroke (p1 => point_1, p2 => point_2, p3 => Point_3, ans => ans_point);
   Initialise (the_point => point_1, with_x => 1.0, and_y => 2.0);
   Initialise (the_point => point_2, with_x => 3.0, and_y => 5.0);
   Initialise (the_point => point_3, with_x => 5.0, and_y => 7.0);
   Initialise (the_point => ans_point, with_x => 3.622, and_y => 5.402);
   Test_Smooth_Stroke (p1 => point_1, p2 => point_2, p3 => Point_3, ans => ans_point);
   Initialise (the_point => point_1, with_x => 2.0, and_y => 4.0);
   Initialise (the_point => point_2, with_x => 4.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 5.0, and_y => 10.0);
   Initialise (the_point => ans_point, with_x => 4.500, and_y => 8.500);
   Test_Smooth_Stroke (p1 => point_1, p2 => point_2, p3 => Point_3, ans => ans_point);
   Initialise (the_point => point_1, with_x => 3.0, and_y => -4.0);
   Initialise (the_point => point_2, with_x => 5.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 6.0, and_y => 10.0);
   Initialise (the_point => ans_point, with_x => 5.773, and_y => 8.441);
   Test_Smooth_Stroke (p1 => point_1, p2 => point_2, p3 => Point_3, ans => ans_point);
   
   Put_Line("Testing Measure distance:");
   Initialise (the_point => point_1, with_x => 0.0, and_y => 0.0);
   Initialise (the_point => point_2, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_3, with_x => 2.0, and_y => 2.0);
   Test_Measure_Distance (p1 => point_1, p2 => point_2, offset => Point_3, ans => 2.0);
   Initialise (the_point => point_1, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_2, with_x => 2.0, and_y => 2.0);
   Initialise (the_point => point_3, with_x => 3.0, and_y => 3.0);
   Test_Measure_Distance (p1 => point_1, p2 => point_2, offset => Point_3, ans => 8.0);
   Initialise (the_point => point_1, with_x => 2.0, and_y => 4.0);
   Initialise (the_point => point_2, with_x => 4.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 5.0, and_y => 10.0);
   Test_Measure_Distance (p1 => point_1, p2 => point_2, offset => Point_3, ans => 45.0);
   Initialise (the_point => point_1, with_x => 3.0, and_y => -4.0);
   Initialise (the_point => point_2, with_x => 5.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 6.0, and_y => 10.0);
   Test_Measure_Distance (p1 => point_1, p2 => point_2, offset => Point_3, ans => 20.0);
   
   Put_Line("Testing Simplify Stroke:");
   Initialise (the_point => point_1, with_x => 0.0, and_y => 0.0);
   Initialise (the_point => point_2, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_3, with_x => 2.0, and_y => 2.0);
   Test_Simplify_Stroke(p1 => point_1, p2 => point_2, p3 => Point_3, ans1=> 2.828, ans2=> 1.414, ans3=>0.0);
   Initialise (the_point => point_1, with_x => 1.0, and_y => 1.0);
   Initialise (the_point => point_2, with_x => 2.0, and_y => 2.0);
   Initialise (the_point => point_3, with_x => 3.0, and_y => 3.0);
   Test_Simplify_Stroke(p1 => point_1, p2 => point_2, p3 => Point_3, ans1=> 2.828, ans2=> 1.414, ans3=>0.0);
   Initialise (the_point => point_1, with_x => 1.0, and_y => 2.0);
   Initialise (the_point => point_2, with_x => 3.0, and_y => 5.0);
   Initialise (the_point => point_3, with_x => 5.0, and_y => 7.0);
   Test_Simplify_Stroke(p1 => point_1, p2 => point_2, p3 => Point_3, ans1=> 6.403, ans2=> 3.592, ans3=>0.312);
   Initialise (the_point => point_1, with_x => 2.0, and_y => 4.0);
   Initialise (the_point => point_2, with_x => 4.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 5.0, and_y => 10.0);
   Test_Simplify_Stroke(p1 => point_1, p2 => point_2, p3 => Point_3, ans1=> 6.708, ans2=> 4.472, ans3=>0.0);
   Initialise (the_point => point_1, with_x => 3.0, and_y => -4.0);
   Initialise (the_point => point_2, with_x => 5.0, and_y => 8.0);
   Initialise (the_point => point_3, with_x => 6.0, and_y => 10.0);
   Test_Simplify_Stroke(p1 => point_1, p2 => point_2, p3 => Point_3, ans1=>14.318, ans2=>12.153, ans3=>0.559);
   
end Test_Vectors;
