/**
 * Creates a bunch (100) of clients and connects them all to a HubNet server
 * and lets them run around at random forever.
 *
 * This class assumes that the clients will be connected to the modified
 * Template model provided in this project.
 *
 * Each client's interfaceSpec field should contain a list with 4 button names.
 *
 * However, should someone desire to change this to connect to model,
 * only the doStuff method would need to be changed.
 *
 * Also important to note: In this code, clients aren't bothering to look
 * at the messages coming from the server (after login). Other files in this
 * project show examples of that.
 */
object HubNetClientMayhem {
  def main(args: Array[String]) {

    // create 100 clients.
    val clients = for (i <- 1 to 100)
      yield new BasicClient(userId=i.toString, clientType="ANDROID")

    // sleep for a bit just to make sure all the clients are connected.
    // more clients probably requires more sleep time.
    Thread.sleep(10000)

    // doStuff forever.
    while(true){
      clients.foreach(doStuff)
      Thread.sleep(200)
    }
  }

  val random = new util.Random()
  // right now, this just chooses a random button for the client to 'click'
  // but really, you could do anything you wanted in here. 
  def doStuff(c:BasicClient){
    c.sendActivityCommand(c.interfaceSpec(random.nextInt(4)).toString, false)
  }
}
