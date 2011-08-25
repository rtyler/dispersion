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

            Hostname : constant String := AWS.Headers.Get_Values (Headers, "Host");
            URL : constant String := "http://" & Hostname & AWS.Status.URI (Request);
            Method : constant AWS.Status.Request_Method := AWS.Status.Method (Request);

            Result : AWS.Response.Data;
        begin
            Put_Line ("Should proxy " & URL);

            Result := AWS.Client.Get (URL => URL,
                                      Follow_Redirection => True);

            declare
                Buf : constant String := AWS.Response.Message_Body (Result);
                Code : constant AWS.Messages.Status_Code := AWS.Response.Status_Code (Result);
            begin
                Put_Line ("Status: " & AWS.Messages.Image (Code));

                return AWS.Response.Build (AWS.Response.Content_Type (Result),
                                           Buf);
            end;
        end Request_Upstream;

        return AWS.Response.Build ("text/html",  "Failed to proxy");
    end Simple;
end Callbacks;
