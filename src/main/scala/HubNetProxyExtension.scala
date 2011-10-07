import java.lang.Thread
import java.net.{Socket, ServerSocket}
import org.nlogo.api._
import org.nlogo.api.Syntax._
import org.nlogo.hubnet.server.HubNetManager

case class Server(serverPort:Int, hubnetPort: Int){
  private val ss:ServerSocket = new ServerSocket(serverPort)
  @volatile private var alive = true
  whileAliveDo{
    val client:Socket = ss.accept()
    val hubnet: Socket = new Socket("127.0.0.1", hubnetPort)
    val raw = new RawProtocol(client.getInputStream, client.getOutputStream)
    val hub = new HubNetProtocol(hubnet.getInputStream, hubnet.getOutputStream)
    whileAliveDo{ hub.writeMessage(raw.readMessage()) }
    whileAliveDo{ raw.writeMessage(hub.readMessage()) }
//    whileAliveDo{ println(raw.readMessage) }
  }
  def stop(){ alive = false }

  def whileAliveDo(f: => Unit){
    new Thread(new Runnable { def run() { while(alive) f } }).start()
  }
}

object HubNetProxyExtension {
  var so: Option[Server] = None
  var em: org.nlogo.workspace.ExtensionManager = null
  def start(port:Int){
    so match {
      case Some(s) => throw new ExtensionException("already listening")
      case None => { so = Some(Server(port, hubNetPort)) }
    }
  }
  def stop(){ so.foreach(_.stop); so = None }
  def hubNetPort =
    em.workspace.getHubNetManager.asInstanceOf[HubNetManager].connectionManager.port
}

class HubNetProxyExtension extends DefaultClassManager {
  def load(manager: PrimitiveManager) {
    manager.addPrimitive("start", new Start)
    manager.addPrimitive("stop", new Stop)
  }
  override def runOnce(em: ExtensionManager) {
    HubNetProxyExtension.em = em.asInstanceOf[org.nlogo.workspace.ExtensionManager]
  }
  override def unload(em: ExtensionManager){ HubNetProxyExtension.stop() }
}

class Start extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(NumberType))
  def perform(args: Array[Argument], context: Context){
    HubNetProxyExtension.start(args(0).getIntValue)
  }
}

class Stop extends DefaultCommand {
  override def getSyntax = commandSyntax(Array[Int]())
  def perform(args: Array[Argument], context: Context){ HubNetProxyExtension.stop() }
}