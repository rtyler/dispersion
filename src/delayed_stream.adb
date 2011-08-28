private with Ada.Text_IO;

package body Delayed_Stream is
    -----------
    -- Close --
    -----------

    procedure Close (File : in out Delayed) is
    begin
        null;
    end Close;

    ------------
    -- Create --
    ------------

    procedure Create
        (Resource       : in out AWS.Resources.Streams.Stream_Type'Class;
        Response       : in out AWS.Response.Data;
        Size           : Stream_Element_Offset;
        Undefined_Size : Boolean) is
    begin
        Delayed (Resource).Undefined_Size := Undefined_Size;
        Delayed (Resource).Size           := Size;
        Delayed (Resource).Offset         := 0;
        Delayed (Resource).Response := Response;

        AWS.Response.Message_Body (Response, Delayed(Resource).Handle);
    end Create;

    -----------------
    -- End_Of_File --
    -----------------

    function End_Of_File
        (Resource : Delayed) return Boolean is
    begin
        return Resource.Offset >= Resource.Size;
    end End_Of_File;

    ----------
    -- Read --
    ----------

    procedure Read
        (Resource : in out Delayed;
        Buffer   : out Stream_Element_Array;
        Last     : out Stream_Element_Offset)
    is
        use Ada.Text_IO;

        Buffer_Length : constant Stream_Element_Offset := Buffer'Last;
        Delay_Interval : constant Float :=  (Float (Buffer_Length) / 7168.0);

        Data_Stream : Ada.Streams.Stream_Element_Array (1 .. Buffer_Length);
        Data_Last   : Ada.Streams.Stream_Element_Offset;
    begin
        Last := Buffer'First - 1;

        AWS.Resources.Read (Resource.Handle, Data_Stream, Data_Last);

        -- If our input stream is empty, might as well bail now, nothing to
        -- write to the output stream
        if Data_Last < 0 then
            return;
        end if;

        delay Duration (Delay_Interval);

        for I in 1 .. Data_Last loop
            Buffer (I) := Data_Stream (I);
            Last := I;
        end loop;
    end Read;

    -----------
    -- Reset --
    -----------

    procedure Reset (File : in out Delayed) is
    begin
        null;
    end Reset;

    ---------------
    -- Set_Index --
    ---------------

    procedure Set_Index
        (File     : in out Delayed;
        Position : Stream_Element_Offset) is
    begin
        null;
    end Set_Index;

    ----------
    -- Size --
    ----------

    function Size (File : Delayed) return Stream_Element_Offset is
    begin
        if File.Undefined_Size then
            return AWS.Resources.Undefined_Length;
        else
            return File.Size;
        end if;
    end Size;

end Delayed_Stream;
