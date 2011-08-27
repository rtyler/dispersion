--
--  Main source file for the Dispersion Proxy
--

private with Ada.Text_IO,
             AWS.Client,
             AWS.Response,
             AWS.Server,
             AWS.Status;

with Callbacks;

procedure Dispersion is
    use Ada.Text_IO;

    Server : AWS.Server.HTTP;

begin
    Put_Line ("Starting Dispersion on port 8980..");

    AWS.Server.Start (Web_Server     => Server,
                      Name           => "Dispersion Proxy",
                      Max_Connection => 5,
                      Port           => 8980,
                      Callback       => Callbacks.Simple'Access);

    Put_Line ("Press 'q' to quit..");

    AWS.Server.Wait (Mode => AWS.Server.Q_Key_Pressed);

    Put_Line ("Shutting down..");
    AWS.Server.Shutdown (Web_Server => Server);
end Dispersion;
