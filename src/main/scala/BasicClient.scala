import java.net.Socket
import java.io.{IOException, ObjectOutputStream}
import java.util.concurrent.{Executors, ExecutorService, TimeUnit, LinkedBlockingQueue}
import org.nlogo.api.{LogoList, Version}
import org.nlogo.hubnet.protocol._
import org.nlogo.util.ClassLoaderObjectInputStream
import collection.JavaConverters._

/**
 * BasicClients handle all the busy work of managing Socket connections to HubNet servers.
 *
 * It isn't necessary to understand the internals of this class, just the public api that it provides.
 *
 * The constructor currently goes ahead and establishes the connection to the server.
 * It throws an exception if it is unable to connect.
 *
 * After construction, activityName and interfaceSpec fields/methods are available.
 * activityName is a String.
 * interfaceSpec is a LogoList that contains different information based on
 * the model being connected to, and the client type. This is more fully explained in
 * HubNetJavaClient.java
 *
 * messagesReceived field/method is a LinkedBlockingQueue that contains all of the
 * messages that this client has received from the server thus far.
 *
 * sendActivityCommand(tag:String, content: Any)
 *   Send an ActivityMessage to the server.
 *   tag is retrived on the server with the hubnet-message-tag primitive.
 *   content with the hubnet-message primitive.
 *
 * close(reason:String)
 *   Send an ExitMessage to the server with the given reason.
 *   The server should will process the exit message and close the connection.
 *   Note that the client doesn't close the connection here first.
 *   Also, this will probably be changed to reason:Option[String] soon.
 *
 * nextMessage(timeoutMillis:Long=200): Option[Message]
 *   Gets the next message from the server, and removes if from the messagesReceived queue.
 *   If there is no message available before the timeout, returns None.
 *
 * TODO: These next two methods I really need to test. I think they discard all other types of
 * messages in the queue. That would be bad.
 *
 * getWidgetControlMessages: List[WidgetControl]
 *   returns a List of all the WidgetContol messages waiting in the messagesReceived queue and
 *   removes them from the queue.
 *
 * getViewUpdateMessages: List[ViewUp]
 *   returns a List of all the ViewUpdate messages waiting in the messagesReceived queue and
 *   removes them from the queue. 
 */
object BasicClient{
  implicit val pool = Executors.newCachedThreadPool()
  // this method exists so that it can be called from Java.
  // Java can't call Scala methods with default arguments, and so can't
  // call the BasicClient constructor below.
  def create(userId: String, clientType: String, ip:String, port:Int) =
    new BasicClient(userId, clientType, ip, port, pool)
}

case class BasicClient(userId: String, clientType: String="COMPUTER", ip:String="127.0.0.1", port:Int=9173,
                       executor: ExecutorService=BasicClient.pool){
  import org.nlogo.hubnet.protocol.{ViewUpdate => ViewUp}

  private val socket = new Socket(ip, port) {setSoTimeout(0)}
  private val in = ClassLoaderObjectInputStream(Thread.currentThread.getContextClassLoader, socket.getInputStream)
  private val out = new ObjectOutputStream(socket.getOutputStream)

  // public api
  val (activityName, interfaceSpec) = handshake()
  lazy val messagesReceived = new LinkedBlockingQueue[Message]

  def sendActivityCommand(tag:String, content: Any){
    send(new ActivityCommand(tag, content.asInstanceOf[AnyRef]))
  }

  def close(reason:String){ send(ExitMessage(reason)) }
  def getWidgetControlMessages: Iterable[WidgetControl] =
    messagesReceived.asScala.collect{ case wc: WidgetControl => wc }
  def getViewUpdateMessages: Iterable[ViewUp] =
    messagesReceived.asScala.collect{ case vu: ViewUp => vu }

  def nextMessage(timeoutMillis:Long=200): Option[Message] =
    Option(messagesReceived.poll(timeoutMillis, TimeUnit.MILLISECONDS))

  // Attempts the handshake and explodes if it fails.
  // This method is called from the constructor.
  private def handshake(): (String, Seq[AnyRef]) = {
    def sendAndReceive(a: AnyRef): AnyRef = {
      rawSend(a)
      in.readObject()
    }
    try{
      val version = sendAndReceive(Version.version)
      val response = sendAndReceive(new HandshakeFromClient(userId, clientType))
      val result = response match {
        case h: HandshakeFromServer =>
          send(EnterMessage)
          executor.submit(new Receiver())
          (h.activityName, h.interfaceSpecList.toSeq)
        case r => throw new IllegalStateException(userId + " handshake failed. response:" + r)
      }
      result
    }catch {
      case e:Exception => throw new IllegalStateException("dead client: " + userId, e)
    }
  }

  // sends a message to the server
  private def send(a: AnyRef) = { rawSend(a) }

  private def rawSend(a: AnyRef){
    out.writeObject(a)
    out.flush()
  }

  private var _dead = false
  def dead = _dead

  // i suppose its quite posible that we don't need this business at all
  // instead, when we need the next message, we can just read it off the socket.
  // we could then get rid of the exector altogether..
  private class Receiver extends Runnable {
    override def run() {
      try {
        messagesReceived.put(in.readObject.asInstanceOf[Message])
        executor.submit(this)
      } catch {
        // keep track of death so that users of BasicClient know.
        // previously we were just dropping this here. bad. JC - 3/31/11
        case e:IOException => _dead = true
      }
    }
  }
}
