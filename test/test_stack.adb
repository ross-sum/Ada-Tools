with dStrings; use dStrings;
with dStrings.IO;   use dStrings.IO;
with Generic_Stack;
procedure Test_Stack is

   zero : constant integer := 0;
   empty_string : constant text := Clear;
   package Integer_Stack is new Generic_Stack(integer, zero);
   package String_Stack is new Generic_Stack(text, empty_string);

begin
   declare
      use Integer_Stack;
      the_stack : stack;
      val : integer;
   begin
      Put("Pushing a series of numbers from 0 to 10 onto the stack...");
      for num in 0 .. 10 loop
         Push(the_item => num, onto => the_stack);
      end loop;
      Put_Line(" Done.");
      Put_Line("Popping them off...");
      for num in 1 .. Depth(of_the_stack => the_stack) loop
         Pop(the_item => val, off_of => the_stack);
         Put_Line("Got " & Put_Into_String(val) & ".");
      end loop;
   end;

   declare
      use String_Stack;
      the_words : constant array(1..10) of text := (Value("Hello"), Value("to"),
                    Value("you"), Value("How"), Value("are"), Value("you"),
          Value("today"), Value("Are"), Value("you"), Value("well"));
      the_stack : stack;
      val  : text;
   begin
      Put_Line("Pushing a series of 10 words onto the stack...");
      Put("Pushing ");
      for num in 1 .. 10 loop
         Put(' ' & the_words(num) & ", ");
         Push(the_item => the_words(num), onto => the_stack);
      end loop;
      Put_Line(" Done.");
      Put_Line("Popping them off...");
      for num in 1 .. Depth(of_the_stack => the_stack) loop
         Pop(the_item => val, off_of => the_stack);
         Put_Line("Got '" & val & "'.");
      end loop;
      null;
   end;

   declare
      use String_Stack;
      the_words : constant array(1..10) of text := (Value("Hello"), Value("to"),
                    Value("you"), Value("How"), Value("are"), Value("you"),
          Value("today"), Value("Are"), Value("you"), Value("well?"));
      the_stack : stack;
      val  : text;
   begin
      Put_Line("Pushing a second series of 10 words onto the stack...");
      Put("Pushing ");
      for num in 1 .. 10 loop
         Put(' ' & the_words(num) & ", ");
         Push(the_item => the_words(num), onto => the_stack);
      end loop;
      Put_Line(" Done.");
      Put_Line("Popping them off...");
      while Depth(of_the_stack => the_stack) > 0 loop
         Pop(the_item => val, off_of => the_stack);
         Put_Line("Got '" & val & "'.");
      end loop;
      null;
   end;

end Test_Stack;

