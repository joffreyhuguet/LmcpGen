with System.Storage_Elements; use System.Storage_Elements;
with GNAT.Byte_Swapping;
with Ada.Unchecked_Conversion;

package body AVTAS.LMCP.ByteBuffers is

   ---------------
   -- Raw_Bytes --
   ---------------

   function Raw_Bytes (This : ByteBuffer) return Byte_Array is
     (This.Content (1 .. This.Length));

   ---------------
   -- Raw_Bytes --
   ---------------

   function Raw_Bytes (This : ByteBuffer) return String is
      Result : String (1 .. Positive (This.Length));
   begin
      for K in 1 .. This.Length loop
         Result (Positive (K)) := Character'Val (This.Content (K));
      end loop;
      return Result;
   end Raw_Bytes;

   ------------
   -- Rewind --
   ------------

   procedure Rewind (This : in out ByteBuffer) is
   begin
      This.Position := 1;
   end Rewind;

   -----------
   -- Clear --
   -----------

   procedure Clear (This : in out ByteBuffer) is
   begin
      This.Rewind;
      This.Length := 0;
   end Clear;

   ---------------
   -- Remaining --
   ---------------

   function Remaining (This : ByteBuffer) return UInt32 is
      (This.Capacity - This.Position + 1);

   -------------------
   -- Has_Remaining --
   -------------------

   function Has_Remaining (This : ByteBuffer) return Boolean is
     (Remaining (This) > 0);

   --------------
   -- Position --
   --------------

   function Position (This : ByteBuffer) return UInt32 is
     (This.Position);

   ------------
   -- Length --
   ------------

   function Length (This : ByteBuffer) return UInt32 is
      (This.Length);

   --------------
   -- Checksum --
   --------------

   function Checksum (This : ByteBuffer;  From, To : Index) return UInt32 is
      Result : UInt32 := 0;
   begin
      for K in Index range From .. To loop
         Result := Result + UInt32 (This.Content (K));
      end loop;
      return Result;
   end Checksum;

   -----------------
   -- Overlapping --
   -----------------

   function Overlapping (Destination, Source : Address; Count : Storage_Count) return Boolean is
     (for some Location in To_Integer (Destination) .. To_Integer (Destination + Count - 1) =>
           Location in To_Integer (Source) .. To_Integer (Source + Count - 1))
   with Pre => Source /= Null_Address and
               Destination /= Null_Address;

   -------------
   -- MemCopy --
   -------------

   function MemCopy (Destination, Source : Address; Count : Storage_Count) return Address with
     Import,
     Convention => C,
     Link_Name => "memcpy",
     Pre => Source /= Null_Address and then
            Destination /= Null_Address and then
            Source /= Destination and then  --- covered by Overlapping test but aids comprehension
            not Overlapping (Destination, Source, Count),
     Post => MemCopy'Result = Destination;
   --  Copies Count bytes from the object designated by Source to the object
   --  designated by Destination. Note the order of the address parameters is
   --  critical so use the named association format for specifying actuals in
   --  calls.

   generic
      type Inserted is private;
   procedure Insert_2_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   with
      Pre => Start in Buffer'Range and then
             Start + 2 - 1 in Buffer'Range;

   generic
      type Inserted is private;
   procedure Insert_4_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   with
      Pre => Start in Buffer'Range and then
             Start + 4 - 1 in Buffer'Range;

    generic
      type Inserted is private;
   procedure Insert_8_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   with
      Pre => Start in Buffer'Range and then
             Start + 8 - 1 in Buffer'Range;

   generic
      type Retrieved is private;
   procedure Retrieve_2_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   with
     Pre => Start in Buffer'Range and then
            Start + 2 - 1 in Buffer'Range;

   generic
      type Retrieved is private;
   procedure Retrieve_4_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   with
     Pre => Start in Buffer'Range and then
            Start + 4 - 1 in Buffer'Range;

   generic
      type Retrieved is private;
   procedure Retrieve_8_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   with
     Pre => Start in Buffer'Range and then
            Start + 8 - 1 in Buffer'Range;

   --------------------
   -- Insert_2_Bytes --
   --------------------

   procedure Insert_2_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 2);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Bytes is new Ada.Unchecked_Conversion (Source => Inserted, Target => Bytes);
   begin
      pragma Compile_Time_Error (Inserted'Object_Size /= 2 * Storage_Unit, "Generic actual param should be 2 bytes");
      Buffer_Overlay := As_Bytes (Value);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap2 (Buffer (Start)'Address);
      end if;
   end Insert_2_Bytes;

   --------------------
   -- Insert_4_Bytes --
   --------------------

   procedure Insert_4_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 4);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Bytes is new Ada.Unchecked_Conversion (Source => Inserted, Target => Bytes);
   begin
      pragma Compile_Time_Error (Inserted'Object_Size /= 4 * Storage_Unit, "Generic actual param should be 4 bytes");
      Buffer_Overlay := As_Bytes (Value);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap4 (Buffer (Start)'Address);
      end if;
   end Insert_4_Bytes;

   --------------------
   -- Insert_8_Bytes --
   --------------------

   procedure Insert_8_Bytes
     (Value  : Inserted;
      Buffer : in out Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 8);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Bytes is new Ada.Unchecked_Conversion (Source => Inserted, Target => Bytes);
   begin
      pragma Compile_Time_Error (Inserted'Object_Size /= 8 * Storage_Unit, "Generic actual param should be 8 bytes");
      Buffer_Overlay := As_Bytes (Value);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap8 (Buffer (Start)'Address);
      end if;
   end Insert_8_Bytes;

   ----------------------
   -- Retrieve_2_Bytes --
   ----------------------

   procedure Retrieve_2_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 2);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Retrieved is new Ada.Unchecked_Conversion (Source => Bytes, Target => Retrieved);
    begin
      pragma Compile_Time_Error (Retrieved'Object_Size /= 2 * Storage_Unit, "Generic actual param should be 2 bytes");
      Value := As_Retrieved (Buffer_Overlay);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap2 (Value'Address);
      end if;
   end Retrieve_2_Bytes;

   ----------------------
   -- Retrieve_4_Bytes --
   ----------------------

   procedure Retrieve_4_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 4);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Retrieved is new Ada.Unchecked_Conversion (Source => Bytes, Target => Retrieved);
   begin
      pragma Compile_Time_Error (Retrieved'Object_Size /= 4 * Storage_Unit, "Generic actual param should be 4 bytes");
      Value := As_Retrieved (Buffer_Overlay);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap4 (Value'Address);
      end if;
   end Retrieve_4_Bytes;

   ----------------------
   -- Retrieve_8_Bytes --
   ----------------------

   procedure Retrieve_8_Bytes
     (Value  : out Retrieved;
      Buffer : Byte_Array;
      Start  : Index)
   is
      subtype Bytes is Byte_Array (1 .. 8);
      Buffer_Overlay : Bytes with Address => Buffer (Start)'Address;
      function As_Retrieved is new Ada.Unchecked_Conversion (Source => Bytes, Target => Retrieved);
   begin
      pragma Compile_Time_Error (Retrieved'Object_Size /= 8 * Storage_Unit, "Generic actual param should be 8 bytes");
      Value := As_Retrieved (Buffer_Overlay);
      if Standard'Default_Scalar_Storage_Order /= System.High_Order_First then -- we're not on a Big Endinan machine
         GNAT.Byte_Swapping.Swap8 (Value'Address);
      end if;
   end Retrieve_8_Bytes;

   --  Instances

   procedure Insert_UInt16 is new Insert_2_Bytes (UInt16) with Inline;

   procedure Retrieve_UInt16 is new Retrieve_2_Bytes (UInt16) with Inline;

   procedure Insert_UInt32 is new Insert_4_Bytes (UInt32) with Inline;

   procedure Retrieve_UInt32 is new Retrieve_4_Bytes (UInt32) with Inline;

   procedure Insert_UInt64 is new Insert_8_Bytes (UInt64) with Inline;

   procedure Retrieve_UInt64 is new Retrieve_8_Bytes (UInt64) with Inline;

   procedure Insert_Int16 is new Insert_2_Bytes (Int16) with Inline;

   procedure Retrieve_Int16 is new Retrieve_2_Bytes (Int16) with Inline;

   procedure Insert_Int32 is new Insert_4_Bytes (Int32) with Inline;

   procedure Retrieve_Int32 is new Retrieve_4_Bytes (Int32) with Inline;

   procedure Insert_Int64 is new Insert_8_Bytes (Int64) with Inline;

   procedure Retrieve_Int64 is new Retrieve_8_Bytes (Int64) with Inline;

   procedure Insert_Float is new Insert_4_Bytes (Real32) with Inline;

   procedure Retrieve_Float is new Retrieve_4_Bytes (Real32) with Inline;

   procedure Insert_Double is new Insert_8_Bytes (Real64) with Inline;

   procedure Retrieve_Double is new Retrieve_8_Bytes (Real64) with Inline;

   --------------
   -- Get_Byte --
   --------------

   procedure Get_Byte (This : in out ByteBuffer; Value : out Byte) is
   begin
      Value := This.Content (This.Position);
      This.Position := This.Position + 1;
   end Get_Byte;

   -----------------
   -- Get_Boolean --
   -----------------

   procedure Get_Boolean (This : in out ByteBuffer; Value : out Boolean) is
   begin
      Value := This.Content (This.Position) /= 0;
      This.Position := This.Position + 1;
   end Get_Boolean;

   ---------------
   -- Get_Int16 --
   ---------------

   procedure Get_Int16 (This : in out ByteBuffer; Value : out Int16) is
   begin
      Retrieve_Int16 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
   end Get_Int16;

   ----------------
   -- Get_UInt16 --
   ----------------

   procedure Get_UInt16 (This : in out ByteBuffer; Value : out UInt16) is
   begin
      Retrieve_UInt16 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
   end Get_UInt16;

   ---------------
   -- Get_Int32 --
   ---------------

   procedure Get_Int32 (This : in out ByteBuffer; Value : out Int32) is
   begin
      Retrieve_Int32 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
   end Get_Int32;

   ----------------
   -- Get_UInt32 --
   ----------------

   procedure Get_UInt32 (This : in out ByteBuffer; Value : out UInt32) is
   begin
      Retrieve_UInt32 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
   end Get_UInt32;

   ----------------
   -- Get_UInt32 --
   ----------------

   procedure Get_UInt32
     (This  : in ByteBuffer;
      Value : out UInt32;
      First : Index)
   is
   begin
      Retrieve_UInt32 (Value, This.Content, Start => First);
      --  Position is unchanged
   end Get_UInt32;

   ---------------
   -- Get_Int64 --
   ---------------

   procedure Get_Int64 (This : in out ByteBuffer; Value : out Int64) is
   begin
      Retrieve_Int64 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
   end Get_Int64;

   ----------------
   -- Get_UInt64 --
   ----------------

   procedure Get_UInt64 (This : in out ByteBuffer; Value : out UInt64) is
   begin
      Retrieve_UInt64 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
   end Get_UInt64;

   ---------------
   -- Get_Real32 --
   ---------------

   procedure Get_Real32 (This : in out ByteBuffer; Value : out Real32) is
   begin
      Retrieve_Float (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
  end Get_Real32;

   ----------------
   -- Get_Real64 --
   ----------------

   procedure Get_Real64 (This : in out ByteBuffer; Value : out Real64) is
   begin
      Retrieve_Double (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
  end Get_Real64;

   ----------------
   -- Get_String --
   ----------------

   procedure Get_String
     (This  : in out ByteBuffer;
      Value : out String;
      Last  : out Natural)
   is
      Result : System.Address with Unreferenced;
      Length : UInt32;
   begin
      Retrieve_Int16 (Int16 (Length), This.Content, Start => This.Position);
      This.Position := This.Position + 2;
      if UInt32 (Length) > (This.Length - This.Position) then
	 Length := UInt32 (This.Length - This.Position);
      end if;
      if Length = 0 then
         Last := Value'First - 1;
      else
         Result := MemCopy (Source      => This.Content (This.Position)'Address,
                            Destination => Value'Address,
                            Count       => Storage_Count (Length));
         This.Position := This.Position + Length;
         Last := Value'First + Natural (Length) - 1;
      end if;
   end Get_String;

   --------------------------
   -- Get_Unbounded_String --
   --------------------------

   procedure Get_Unbounded_String
     (This  : in out ByteBuffer;
      Value : out Unbounded_String)
   is
      Result : System.Address with Unreferenced;
      Length : UInt16;
   begin
      Retrieve_UInt16 (Length, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
      if UInt32 (Length) > (This.Length - This.Position) then
	 Length := UInt16 (This.Length - This.Position);
      end if;
      if Length = 0 then
         Value := Null_Unbounded_String;
      else
         declare
            S : String (1 .. Integer (Length));
         begin
            Result := MemCopy (Source      => This.Content (This.Position)'Address,
                               Destination => S'Address,
                               Count       => Storage_Count (Length));
            This.Position := This.Position + Index (Length);
            Value := To_Unbounded_String (S);
         end;
      end if;
   end Get_Unbounded_String;

   --------------
   -- Put_Byte --
   --------------

   procedure Put_Byte (This : in out ByteBuffer; Value : Byte) is
   begin
      This.Content (This.Position) := Value;
      This.Position := This.Position + 1;
      This.Length := This.Length + 1;
   end Put_Byte;

   -----------------
   -- Put_Boolean --
   -----------------

   procedure Put_Boolean (This : in out ByteBuffer; Value : Boolean) is
   begin
      This.Content (This.Position) := (if Value then 1 else 0);
      This.Position := This.Position + 1;
      This.Length := This.Length + 1;
   end Put_Boolean;

   ---------------
   -- Put_Int16 --
   ---------------

   procedure Put_Int16 (This : in out ByteBuffer; Value : Int16) is
   begin
      Insert_Int16 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
      This.Length := This.Length + 2;
   end Put_Int16;

   ----------------
   -- Put_UInt16 --
   ----------------

   procedure Put_UInt16 (This : in out ByteBuffer; Value : UInt16) is
   begin
      Insert_UInt16 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
      This.Length := This.Length + 2;
   end Put_UInt16;

   ---------------
   -- Put_Int32 --
   ---------------

   procedure Put_Int32 (This : in out ByteBuffer; Value : Int32) is
   begin
      Insert_Int32 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
      This.Length := This.Length + 4;
   end Put_Int32;

   ----------------
   -- Put_UInt32 --
   ----------------

   procedure Put_UInt32 (This : in out ByteBuffer; Value : UInt32) is
   begin
      Insert_UInt32 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
      This.Length := This.Length + 4;
   end Put_UInt32;

   ---------------
   -- Put_Int64 --
   ---------------

   procedure Put_Int64 (This : in out ByteBuffer; Value : Int64) is
   begin
      Insert_Int64 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
      This.Length := This.Length + 8;
   end Put_Int64;

   ----------------
   -- Put_UInt64 --
   ----------------

   procedure Put_UInt64 (This : in out ByteBuffer; Value : UInt64) is
   begin
      Insert_UInt64 (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
      This.Length := This.Length + 8;
   end Put_UInt64;

   ---------------
   -- Put_Real32 --
   ---------------

   procedure Put_Real32 (This : in out ByteBuffer; Value : Real32) is
   begin
      Insert_Float (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 4;
      This.Length := This.Length + 4;
  end Put_Real32;

   ----------------
   -- Put_Real64 --
   ----------------

   procedure Put_Real64 (This : in out ByteBuffer; Value : Real64) is
   begin
      Insert_Double (Value, This.Content, Start => This.Position);
      This.Position := This.Position + 8;
      This.Length := This.Length + 8;
  end Put_Real64;

   ----------------
   -- Put_String --
   ----------------

   procedure Put_String (This : in out ByteBuffer;  Value : String) is
      Result : System.Address with Unreferenced;
   begin
      Insert_Int16 (Value'Length, This.Content, Start => This.Position);
      This.Position := This.Position + 2;
      Result := MemCopy (Destination => This.Content (This.Position)'Address,
                         Source      => Value'Address,
                         Count       => Storage_Count (Value'Length));
      This.Position := This.Position + Value'Length;
      This.Length := This.Length + 2 + Value'Length;
   end Put_String;

   -------------------
   -- Put_Raw_Bytes --
   -------------------

   procedure Put_Raw_Bytes ( This : in out ByteBuffer; Value : String) is
      Result : System.Address with Unreferenced;
   begin
      Result := MemCopy (Destination => This.Content (This.Position)'Address,
                         Source      => Value'Address,
                         Count       => Storage_Count (Value'Length));
      This.Position := This.Position + Value'Length;
      This.Length := This.Length + Value'Length;
   end Put_Raw_Bytes;

   --------------------------
   -- Put_Unbounded_String --
   --------------------------

   procedure Put_Unbounded_String (This : in out ByteBuffer;  Value : Unbounded_String) is
   begin
      This.Put_String (To_String (Value));
   end Put_Unbounded_String;

end AVTAS.LMCP.ByteBuffers;
