with Blobs, Blobs.Base_64; use Blobs, Blobs.Base_64;
with Ada.Text_IO; use Ada.Text_IO;
procedure Test_Base_64 is
   blob_1 : blob(1..1);
   blob_2 : blob(1..2);
   blob_3 : blob(1..3);
   blob_6 : blob(1..6);
begin
   blob_1(1) := Character'Pos('A');
   Put_Line("Base 64 of 'A' is '" & Encode(blob_1) & "'.");
   Put_Line("Inverse of this is '" & Decode(Encode(blob_1)) & "'.");
   blob_2(1) := Character'Pos('A');
   blob_2(2) := Character'Pos('B');
   Put_Line("Base 64 of 'AB' is '" & Encode(blob_2) & "'.");
   Put_Line("Inverse of this is '" & Decode(Encode(blob_2)) & "'.");
   blob_3(1) := Character'Pos('A');
   blob_3(2) := Character'Pos('B');
   blob_3(3) := Character'Pos('C');
   Put_Line("Base 64 of 'ABC' is '" & Encode(blob_3) & "'.");
   Put_Line("Inverse of this is '" & Decode(Encode(blob_3)) & "'.");
   blob_6(1..3) := blob_3; blob_6(4..6) := blob_3;
   Put_Line("Base 64 of 'ABCABC' is '" & Encode(blob_6) & "'.");
   Put_Line("Inverse of this is '" & Decode(Encode(blob_6)) & "'.");
end Test_Base_64;
