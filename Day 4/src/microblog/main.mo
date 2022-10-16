import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Time "mo:base/Time";
import List "mo:base/List";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";

actor {
    public type Message = {
        text: Text;
        time: Time.Time;
    };

    public type Microblog = actor {
        follow: shared(Principal) -> async (); 
        follower: shared query () -> async [Principal]; 
        post: shared (Text) -> async (); 
        posts: shared query (Time.Time) -> async [Message]; 
        timeline: shared (Time.Time) -> async [Message]; 
    };

    stable var followed: List.List<Principal> = List.nil();

    stable var messages : List.List<Message> = List.nil();

    public shared func follow(id: Principal) : async () {
        followed := List.push(id, followed);
    }; 

    public shared query func follower() : async [Principal] {
        List.toArray(followed);
    };

    public shared func post(text: Text) : async () {
        let poster ={
            text=text;
            time = Time.now();
        };
        messages := List.push(poster, messages);
    };

    public shared query func posts(since: Time.Time) : async [Message] {
        var newMsgs : List.List<Message> = List.nil();
        for (msg in Iter.fromList(messages)) {
            Debug.print("since: " # Int.toText(since));
            Debug.print("msg.time: " # Int.toText(msg.time));
            if (msg.time > since) {
                newMsgs := List.push(msg, newMsgs);
            }
        };
        List.toArray(newMsgs);
    };

    public shared func timeline(since: Time.Time) : async [Message] {
        var all : List.List<Message> = List.nil();

        for(id in Iter.fromList(followed)) {
            let canister : Microblog = actor(Principal.toText(id));
            let msgs: [Message] = await canister.posts(since);
            all := List.append<Message>(List.fromArray(msgs), all);
        };

        List.toArray(all);
    };
};
