with AWS.Response,
             AWS.Status;

package Callbacks is
    function Simple (Request : AWS.Status.Data) return AWS.Response.Data;

    Invalid_Request : exception;
end Callbacks;
