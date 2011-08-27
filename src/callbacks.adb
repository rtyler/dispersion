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
            Response_Code : AWS.Messages.Status_Code;
        begin
            Put_Line ("Should proxy " & URL);

            Result := AWS.Client.Get (URL => URL,
                                      Follow_Redirection => False);
            Response_Code := AWS.Response.Status_Code (Result);

            Put_Line ("Status: " & AWS.Messages.Image (Response_Code));

            case Response_Code is

                -- Handle passing back redirections
                when AWS.Messages.S300 .. AWS.Messages.S307 =>
                    if Response_Code = AWS.Messages.S301 then
                        return AWS.Response.Moved (AWS.Response.Location (Result));
                    else
                        return AWS.Response.URL (AWS.Response.Location (Result));
                    end if;

                -- Everything else we can slowly proxy
                when others =>
                    declare
                        Buf : constant String := AWS.Response.Message_Body (Result);
                    begin
                        return AWS.Response.Build (Content_Type => AWS.Response.Content_Type (Result),
                                                   Message_Body => Buf,
                                                   Status_Code  => Response_Code);
                    end;
            end case;
        end Request_Upstream;

        return AWS.Response.Build (Content_Type => "text/html", 
                                   Message_Body => "Failed to proxy",
                                   Status_Code  => AWS.Messages.S500);
    end Simple;
end Callbacks;
