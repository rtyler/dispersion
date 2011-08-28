--
--
--

with Ada.Streams,
     AWS.Response,
     AWS.Resources,
     AWS.Resources.Streams;


package Delayed_Stream is
    use Ada.Streams,
        AWS.Resources;

    type Delayed is new Streams.Stream_Type with private;

    function End_Of_File (Resource : Delayed) return Boolean;

    procedure Read
        (Resource : in out Delayed;
        Buffer   : out Stream_Element_Array;
        Last     : out Stream_Element_Offset);

    function Size (File : Delayed) return Stream_Element_Offset;

    procedure Close (File : in out Delayed);

    procedure Reset (File : in out Delayed);

    procedure Set_Index
        (File     : in out Delayed;
        Position : Stream_Element_Offset);

    procedure Create
        (Resource       : in out AWS.Resources.Streams.Stream_Type'Class;
        Response        : in out AWS.Response.Data;
        Size           : Stream_Element_Offset;
        Undefined_Size : Boolean);

private

    type Delayed is new Streams.Stream_Type with record
        Offset         : Stream_Element_Offset;
        Size           : Stream_Element_Offset;
        Undefined_Size : Boolean;
        Response       : AWS.Response.Data;
        Handle         : AWS.Resources.File_Type;
    end record;

end Delayed_Stream;
