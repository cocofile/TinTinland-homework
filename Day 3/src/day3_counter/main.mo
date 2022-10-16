import Nat "mo:base/Nat";
import Blob "mo:base/Blob";
import Text "mo:base/Text";

actor Counter {

    public type HeaderField = (Text, Text);
    public type HttpRequest = {
        url : Text;
        method : Text;
        body : Blob;
        headers : [HeaderField];
    };
    public type HttpResponse = {
        body : [Nat8];
        headers : [HeaderField];
        status_code : Nat16;
    };
   
    stable var counter : Nat = 0;

    public func set(x: Nat) : async() {
        counter := x;
    };

    public func add() : async () {
        counter += 1;
    };

    public func get() : async Nat{
        counter
    };

    public query func http_request(arg: HttpRequest) : async HttpResponse {
        {
            body = Blob.toArray(Text.encodeUtf8("<html><body><h1> The Counter now is " #Nat.toText(counter) #"</h1></body></html>"));
            headers = [];
            streaming_strategy = null;
            status_code = 200;
        }
    };
}