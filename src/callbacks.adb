private with Ada.Streams,
             Ada.Text_IO,
             AWS.Client,
             AWS.Headers,
             AWS.Messages,
             AWS.Response,
             AWS.Status;

package body Callbacks is
    use Ada.Text_IO;

    function Simple (Request : AWS.Status.Data) return AWS.Response.Data is
        use AWS.Headers;

        Headers : constant AWS.Headers.List := AWS.Status.Header (Request);
    begin

        if Headers = AWS.Headers.Empty_List then
            raise Invalid_Request;
        end if;

        Put_Line ("Method: " & AWS.Status.Method (Request));
        Put_Line ("URI: " & AWS.Status.URI (Request));


        Put_Line ("Delaying 500ms");
        delay 0.5;

        Request_Upstream : declare
            use Ada.Streams,
                AWS.Messages;

            Connection : AWS.Client.HTTP_Connection;
            Hostname : constant String := AWS.Headers.Get_Values (Headers, "Host");
            URL : constant String := "http://" & Hostname & AWS.Status.URI (Request);
            Method : constant AWS.Status.Request_Method := AWS.Status.Method (Request);

            Result : AWS.Response.Data;
            Message_Body : AWS.Status.Stream_Element_Array (1 .. 10_000);
            Last : AWS.Status.Stream_Element_Offset;
        begin
            Put_Line ("Should proxy " & URL);

            AWS.Client.Create (Connection, URL);

            AWS.Client.Get (Connection, Result);
            Put_Line ("Status: " & AWS.Messages.Image (AWS.Response.Status_Code (Result)));

            declare
                Buf : constant String := AWS.Response.Message_Body (Result);
            begin
                return AWS.Response.Build (AWS.Response.Content_Type (Result),
                                           Buf);
            end;
        end Request_Upstream;

        return AWS.Response.Build ("text/html",  "Failed to proxy");
    end Simple;
end Callbacks;
