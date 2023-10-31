   with Ada.Wide_Text_IO;        use Ada.Wide_Text_IO;
   with dStrings;                use dStrings;
   with Test_Generic_Binary_Trees_Lib;
   use Test_Generic_Binary_Trees_Lib;
	with Ada.Characters.Handling; use Ada.Characters.Handling;

   procedure Test_Generic_Binary_Trees is
   
      use Test_Generic_Binary_Trees_Lib.String_Binary_Trees;
      use Test_Generic_Binary_Trees_Lib.String_Binary_Trees_Find;
   
      a_tree : String_Binary_Trees.list;
      item_1 : constant wide_string := "The Cat sat on the mat";
      item_2 : constant wide_string := "Mary had a little lamb";
      item_3 : constant wide_string := "Its fleece was as black as charcoal";
      item_4 : constant wide_string := "My dog is big";
      item_5 : constant wide_string := "The cow jumped over the moon";
      item_6 : constant wide_string := "Hey diddle diddle.";
      item_7 : constant wide_string := "the cat and the fiddle";
      item_8 : constant wide_string := "the little dog laughed to see such fun";
      item_9 : constant wide_string := "and the dish ran away with the spoon.";
      item_10: constant wide_string := "What about that?";
      item_11: constant wide_string := "The Dog is home.";
      rubbish: constant wide_string := "some unloaded rubbish";
   
      procedure Search_And_Find(a_tree: in out String_Binary_Trees.List) is
         procedure Find_It(numberth, for_value : wide_string) is
         begin
            if The_List_Contains(To_Text(for_value), 
            in_the_list=>a_tree) then
               Put_Line("The " & numberth & 
                  " item loaded is in the tree.");
               Find(To_Text(for_value), in_the_list=>a_tree);
               if not Is_End(of_the_list=>a_tree) then
                  Put_Line("It is '" & 
                     Value(Deliver(from_the_list=>a_tree)) & "'.");
               else
                  Put_Line("It was not located.");
               end if;
            else
               Put_Line("The " & numberth & " item (" & for_value & 
                  ") is not there.");
            end if;
         end Find_It;
      begin
         Find_It("fourth",  item_4);
         Find_It("first",   item_1);
         Find_It("second",  item_2);
         Find_It("sixth",   item_6);
         Find_It("ninth",   item_9);
         Find_It("tenth",   item_10);
         Find_It("fifth",   item_5);
         Find_It("rubbish", rubbish);
      end Search_And_Find;
   
      any_key : wide_character;
   begin
      -- Initial checks
      if Is_Empty(a_tree) then
         Put_Line("The tree is empty.");
      else
         Put_Line("The tree contains data.");
      end if;
      Put_Line("The tree is " & 
   	   To_Wide_String(Integer'Image(Depth(a_tree))) & " deep.");
   	-- Add some values in to the tree
      Insert(into=>a_tree, the_data=>To_Text(item_1));
      Put_Line("1. Loaded '" & item_1 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_2));
      Put_Line("2. Loaded '" & item_2 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_3));
      Put_Line("3. Loaded '" & item_3 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_4));
      Put_Line("4. Loaded '" & item_4 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_5));
      Put_Line("5. Loaded '" & item_5 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_6));
      Put_Line("6. Loaded '" & item_6 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_7));
      Put_Line("7. Loaded '" & item_7 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_8));
      Put_Line("8. Loaded '" & item_8 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_9));
      Put_Line("9. Loaded '" & item_9 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_10));
      Put_Line("10. Loaded '" & item_10 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_11));
      Put_Line("11. Loaded '" & item_11 & "'.");
      if Is_Empty(a_tree) then
         Put_Line("The tree is empty.");
      else
         Put_Line("The tree contains data.");
      end if;
      Put_Line("The tree is " &
   	   To_Wide_String(Integer'Image(Depth(a_tree))) & " deep.");
      New_Line;
   
   	-- Print out the sorted list
      First(in_the_list => a_tree);
      Put_Line("List of objects");
      Put_Line("---------------");
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & To_String(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      New_Line;
   
   	-- Test find and associates
      Put_Line("Search and Find");
      Put_Line("---------------");
      Search_And_Find(a_tree);
   	-- Partial find
      Put_Line("  The full key for starting with 'What' is '" &
         To_String(The_Full_Key (for_partial_key=>To_Text("What"),
         in_the_list=>a_tree)) & "'.");
      Put_Line("  The full key for starting with 'Mary' is '" &
         Value(The_Full_Key (for_partial_key=>Value("Mary"),
         in_the_list=>a_tree)) & "'.");
      New_Line;
   
      Put_Line("Delete");
      Put_Line("------");
      Put_Line("Deleting the fifth object loaded...");
      if The_List_Contains(To_Text(item_5), in_the_list=>a_tree) then
         Put_Line("The fifth item loaded is in the tree.");
         Find(To_Text(item_5), in_the_list=>a_tree);
         if not Is_End(of_the_list=>a_tree) then
            Put_Line("It is '" & 
               Value(Deliver(from_the_list=>a_tree)) & "'.");
            Delete(from_the_list=>a_tree);
         else
            Put_Line("It was not located.");
         end if;
      else
         Put_Line("The fifth item (" & item_5 & ") is not there.");
      end if;
      Put_Line("Object list:");
      First(in_the_list => a_tree);
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & Value(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      Search_And_Find(a_tree);
      Put_Line("Deleting the eleventh object loaded...");
      if The_List_Contains(To_Text(item_11), in_the_list=>a_tree) then
         Put_Line("The eleventh item loaded is in the tree.");
         Find(To_Text(item_11), in_the_list=>a_tree);
         if not Is_End(of_the_list=>a_tree) then
            Put_Line("It is '" & 
               To_String(Deliver(from_the_list=>a_tree)) & "'.");
            Delete(from_the_list=>a_tree);
         else
            Put_Line("It was not located.");
         end if;
      else
         Put_Line("The eleventh item (" & item_11 & ") is not there.");
      end if;
      Put_Line("Object list:");
      First(in_the_list => a_tree);
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & Value(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      Put_Line("Deleting the eighth object loaded...");
      if The_List_Contains(To_Text(item_8), in_the_list=>a_tree) then
         Put_Line("The eighth item loaded is in the tree.");
         Find(To_Text(item_8), in_the_list=>a_tree);
         if not Is_End(of_the_list=>a_tree) then
            Put_Line("It is '" & 
               To_String(Deliver(from_the_list=>a_tree)) & "'.");
            Delete(from_the_list=>a_tree);
         else
            Put_Line("It was not located.");
         end if;
      else
         Put_Line("The eighth item (" & item_8 & ") is not there.");
      end if;
      Put_Line("Object list:");
      First(in_the_list => a_tree);
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & Value(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      Put_Line("Checking all has been deleted:");
      Search_And_Find(a_tree);
      New_Line;
   
      Put_Line("Adds after Deletes");
      Put_Line("------------------");
      Insert(into=>a_tree, the_data=>To_Text(item_5));
      Put_Line("5. Loaded '" & item_5 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_11));
      Put_Line("11. Loaded '" & item_11 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_8));
      Put_Line("8. Loaded '" & item_8 & "'.");
      Put_Line("Object list:");
      First(in_the_list => a_tree);
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & To_String(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      New_Line;
   
      Put_Line("Stress (memory leakage) Test");
      Put_Line("----------------------------");
      for big_loop in 1..5 loop
         Put("Press any key when ready >");
         Get_Immediate(any_key); New_Line;
         Put_Line("Inserting:");
         for cntr in 1..1000 loop
            Insert(into=> a_tree, the_data=> Value(Integer'Image(cntr)));
            Put(To_Wide_String(Integer'Image(cntr)));
         end loop;
         New_Line;
         Put("Press any key when ready >");
         Get_Immediate(any_key); New_Line;
         Put_Line("Deleting:");
         for cntr in 1..1000 loop
            Find(Value(Integer'Image(cntr)), in_the_list=>a_tree);
            Put(To_Wide_String(Integer'Image(cntr)));
            if not Is_End(of_the_list=>a_tree) then
               Delete(from_the_list=>a_tree);
            else
               Put_Line(" was not located.");
            end if;
         end loop;
         New_Line;
      end loop;
      Put("Press any key when ready >");
      Get_Immediate(any_key); New_Line;
   	
   	Put_Line("Insert after full Delete Test");
      Put_Line("-----------------------------");
   	Put("Deleting...");
   	First(in_the_list => a_tree);
   	while not Is_End(of_the_list => a_tree) loop
   	   Delete(from_the_list => a_tree);
   	end loop;
   	Put_Line(" Done.");
   	Put("Adding...");
      Insert(into=>a_tree, the_data=>To_Text(item_5));
      Put_Line("5. Loaded '" & item_5 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_11));
      Put_Line("11. Loaded '" & item_11 & "'.");
      Insert(into=>a_tree, the_data=>To_Text(item_8));
      Put_Line("8. Loaded '" & item_8 & "'.");
      Put_Line("Object list:");
      First(in_the_list => a_tree);
      while not Is_End(of_the_list => a_tree) loop
         Put_Line("  " & To_String(Deliver(from_the_list=>a_tree)));
         Next(in_the_list => a_tree);
      end loop;
      New_Line;
      Put("Press any key when ready >");
      Get_Immediate(any_key); New_Line;	
   	
   end Test_Generic_Binary_Trees;