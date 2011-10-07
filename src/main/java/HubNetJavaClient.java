import org.nlogo.api.LogoList;
import org.nlogo.hubnet.protocol.Message;

import java.util.Random;

/**
  A standalone HubNet client example.

  In order to use this client, start up a modified version of the HubNet Template model.
  The HubNet Template model is a very simple model that allows clients to connect and
  move a turtle around the world, and not much else.
  The modification needed is very small, and I've provided the modified version.
  However, you could also open and modify the Template model from the models library yourself.
  Only one new line is needed, the line after hubnet-reset.

  to startup
    hubnet-reset
    hubnet-set-client-interface "ANDROID" ["up" "down" "left" "right"]
  end

  The rest of this doc aims to explain what that line means.

  Previously in HubNet models you were forced to call:
  hubnet-set-client-interface "COMPUTER" []
  with exactly those arguments. No other arguments were allowed and the call had to be
  made for HubNet to work properly. This made very little sense to me, and in 5.0
  making this call is no longer a requirement.

  The original intent of the call was to allow different client types.
  Now, not only is it not a requirement to add the built in "COMPUTER" client type, but
  you can actually use it to register different client types.
  In a HubNet model (typically in startup) you can now say:
  hubnet-set-client-interface "ANDROID" ["up" "down" "left" "right"]
  hubnet-set-client-interface "IPHONE" ["hello" "world"]

  The last argument to the call is a logo list (["up" "down" "left" "right"] in the ANDROID case)
  This list is sent to any ANDROID clients when they log in.
  This argument is used for the client interface.
  Since each model has a different interface, you need to send the interface from the
  server to the client when the client logs in.

  In this case, I send ["up" "down" "left" "right"] because those are the buttons
  on the regular client in the Template Model. The example client below will randomly
  "press" those buttons. There is other widgets on the regular client, but those are
  simply unknown to this client. Gradually, I could build this client up to support
  different widget types. I would imagine that this is the same sort of process that
  would take place if you were developing your own HubNet client from scratch.

  Eventually, you might build up to more sophisticated here, such as:

  let my-interface-as-xml "<my-interface>...</my-interface>"
  hubnet-set-client-interface "ANDROID" (list my-interface-as-xml)

  For some clients, it might make sense to build your own interface, and possibly even have your
  own tool for building that interface that gets sent to the client.
  But for many other clients, it might make more sense to just parse our current interface data,
  instead of having to supply their own data. This data represents the widgets added in the
  HubNet Client Editor, and what the regular HubNet client would see.
  To use this data instead, a client can just connect with clientType="COMPUTER" instead of
  "ANDROID", "IPHONE", etc.

  Beware though, the current information that comes over is very messy, and undocumented,
  and is definitely going to be changed significantly for NetLogo 5.1. I do have some rough
  documentation on it though, in its current form, and I would be willing to provide it.
 */
public class HubNetJavaClient {

  static public void main(String[] args) {

    // The line below creates an actual connection to a HubNet server with:
    // username=josh, clientType=ANDROID on ip=127.0.0.1, port=9173
    final BasicClient client = BasicClient.create("josh", "ANDROID", "127.0.0.1", 9173);

    // After the client connects, these two methods can be called, and
    // are guaranteed to hold good data.
    // The activity name will be the name of the model, such as Template.
    String activityName = client.activityName();
    // And the interface spec will contain the list mentioned above
    // ["up" "down" "left" "right"] for ANDROID here.
    // Once again, for COMPUTER clients, the list contains something far different
    // and I'll provide the docs for it if needed.
    scala.collection.Seq<Object> interfaceSpec = client.interfaceSpec();

    // I print this out just so that you can verify things are working properly.
    // The second call is especially useful if you try to use the "COMPUTER" client type.
    System.out.println("client.activityName() = " + activityName);
    System.out.println("client.interfaceSpec() = " + interfaceSpec);

    // Set up a thread that will receive and process all the messages from the server.
    Thread receiverThread = new Thread(new Runnable() {
      public void run() {
        while (true) {
          try {
            // Get the next message from the server
            Message message = client.messagesReceived().take();
            // Just print it. Obviously, you might want to do something else with it.
            System.out.println(message);
          } catch (InterruptedException e) {
            e.printStackTrace();
          }
        }
      }
    });
    receiverThread.start();

    // Next (and forever) randomly choose a button to press, and
    // send an activity command to the server with the name of the button
    // (this is what happens when the a regular client clients a button).
    Random r = new Random();
    while (true) {
      String buttonToPress = interfaceSpec.apply(r.nextInt(interfaceSpec.size())).toString();
      client.sendActivityCommand(buttonToPress, false);
      try {
        Thread.sleep(1000);
      } catch (InterruptedException e) {
        e.printStackTrace();
      }
    }
  }
}

/**
More notes:

  The static method TestClient.create actually goes ahead and establishes the connection
  as opposed to giving you back a TestClient object back which you would then
  call a .connect() method on. This could easily be changed. For example, I could
  provide TestClient.create, and TestClient.connect.

  I've thought about encapsulating the message processing part (receiverThread)
  in the TestClient class, having users pass in some sort of MessageProcessor
  object. Doing so would mean that users wouldn't have to go through the
  trouble of setting up and running their own thread, but gives them less
  control over when they process the messages. They would simply get processed
  as they were received (as long as the client could keep up).

  There are several different types of messages coming from the server,
  and each has different fields, all of which need documenting.
  Hopefully I can get to this at some point.

  The sendActivityCommand method takes a two arguments:
  the first corresponds the hubnet-message-tag as described in the HubNet documentation
  and the second corresponds to hubnet-message.
  For buttons, false here means that this button is not a forever button.
  I wanted to leave that last sentence out because it is rather confusing.
  HubNet doesn't even support forever buttons, so for buttons, this argument must
  always be false.
  For other widget types, you would send different data in the second argument.
  This all needs quite a bit more documentation, clearly.
  Now that this is api is freed up, it can mean that the first argument
  (hubnet-message-tag) doesnt correspond to a widget at all, but is free to mean
  whatever you want it to mean.
  More to come on all of this soon.
**/