import java.io._
import org.nlogo.hubnet.protocol._

case class RawProtocol(in:InputStream, out:OutputStream) {
  val dataIn = new DataInputStream(in)
  val dataOut = new DataOutputStream(out)
  def readMessage(): AnyRef = RawProtocol.readMessage(dataIn)
  def writeMessage(m:AnyRef) { RawProtocol.writeMessage(m, dataOut) }
}

case class HubNetProtocol(in:InputStream, out:OutputStream) {
  val oIn = new ObjectInputStream(in)
  val oOut = new ObjectOutputStream(out)
  def readMessage(): AnyRef = oIn.readObject
  def writeMessage(m:AnyRef) { oOut.writeObject(m) }
}

object RawProtocol {
  val HANDSHAKE_FROM_SERVER = 0
  val HANDSHAKE_FROM_CLIENT = 1
  val LOGIN_FAILURE = 2
  val EXIT = 3
  val WIDGET_CONTROL = 4
  val DISABLE_VIEW = 5
  val VIEW_UPDATE = 6
  val PLOT_CONTROL = 7
  val PLOT_UPDATE = 8
  val OVERRIDE = 9
  val CLEAR_OVERRIDE = 10
  val AGENT_PERSPECTIVE = 11
  val TEXT = 12
  val ENTER = 13
  val ACTIVITY_COMMAND = 14
  val VERSION = 15

  def readMessage(in:DataInputStream): AnyRef = {
    def readString(): String = {
      val length = in.readInt()
      val bytes = new Array[Byte](length)
      in.read(bytes)
      new String(bytes)
    }
    def readAny(): AnyRef = {
      val contentType = in.readInt()
      contentType match {
        case 0 => readString()
        case 1 => in.readDouble().asInstanceOf[AnyRef]
        case 2 => in.readBoolean().asInstanceOf[AnyRef]
      }
    }
    val messageId = in.readInt()
    val theMessage = messageId match {
      case HANDSHAKE_FROM_SERVER => sys.error("implement me")
      case HANDSHAKE_FROM_CLIENT => HandshakeFromClient(readString(), readString())
      case LOGIN_FAILURE => LoginFailure(readString())
      case EXIT => ExitMessage(readString())
      case WIDGET_CONTROL => WidgetControl(readAny(), readString())
      case DISABLE_VIEW => DisableView
      case VIEW_UPDATE => sys.error("implement me")
      case PLOT_CONTROL => sys.error("implement me")
      case PLOT_UPDATE => sys.error("implement me")
      case OVERRIDE => sys.error("implement me")
      case CLEAR_OVERRIDE => ClearOverrideMessage
      case AGENT_PERSPECTIVE => sys.error("implement me")
      case TEXT => Text(readString(), in.readInt() match {
        case 0 => Text.MessageType.TEXT
        case 1 => Text.MessageType.USER
        case 2 => Text.MessageType.CLEAR
      })
      case ENTER => EnterMessage
      case ACTIVITY_COMMAND => ActivityCommand(readString(), readAny())
      case VERSION => readString()
    }
    println("read message:" + theMessage)
    theMessage
  }

  def writeMessage(hubNetMessage:AnyRef, out: DataOutputStream) {
    def writeString(s:String) {
      out.writeInt(s.length)
      out.write(s.getBytes)
    }
    def writeAny(content:Any){
      if (content.isInstanceOf[String]) {
        out.writeInt(0)
        writeString(content.toString)
      }
      else if (content.isInstanceOf[Double]) {
        out.writeInt(1)
        out.writeDouble(content.asInstanceOf[Double])
      }
      else if (content.isInstanceOf[Boolean]) {
        out.writeInt(2)
        out.writeBoolean(content.asInstanceOf[Boolean])
      }
    }
    // first write the HubNetMessage id
    out.writeInt(getMessageId(hubNetMessage))
    // the write the fields for the HubNetMessage
    hubNetMessage match {
      case HandshakeFromServer(model, interface) => writeString(model)
      case HandshakeFromClient(userId, clientType) =>
        writeString(userId)
        writeString(clientType)
      case LoginFailure(content) => writeString(content)
      case ExitMessage(reason) => writeString(reason)
      case WidgetControl(content, tag) =>
        writeAny(content)
        writeString(tag)
      case DisableView => // no fields! done.
      case ViewUpdate(worldData) => sys.error("implement me")// TODO: worldData is tough
      case PlotControl(content, plotName) => sys.error("implement me")
      case PlotUpdate(plot) => sys.error("implement me")
      case OverrideMessage(data, clear) => sys.error("implement me")
      case ClearOverrideMessage => // no fields! done.
      case AgentPerspectiveMessage(bytes) => sys.error("implement me") // TODO: no idea what these bytes are
      case Text(content, messageType) =>
        writeString(content)
        out.writeInt(messageType match {
          case Text.MessageType.TEXT => 0
          case Text.MessageType.USER => 1
          case Text.MessageType.CLEAR => 2
        })
      case EnterMessage => // no fields.
      case ActivityCommand(tag, content) =>
        writeString(tag)
        writeAny(content)
      case s:String => writeString(s)
    }
  }

  def getMessageId(hubNetMessage:AnyRef): Int = hubNetMessage match {
    case s:String => VERSION
    case m: HandshakeFromServer => HANDSHAKE_FROM_SERVER
    case m: HandshakeFromClient => HANDSHAKE_FROM_CLIENT
    case m: LoginFailure => LOGIN_FAILURE
    case m: ExitMessage => EXIT
    case m: WidgetControl => WIDGET_CONTROL
    case DisableView => DISABLE_VIEW
    case m: ViewUpdate => VIEW_UPDATE
    case m: PlotControl => PLOT_CONTROL
    case m: PlotUpdate => PLOT_UPDATE
    case m: OverrideMessage => OVERRIDE
    case ClearOverrideMessage => CLEAR_OVERRIDE
    case m: AgentPerspectiveMessage => AGENT_PERSPECTIVE
    case m: Text => TEXT
    case EnterMessage => ENTER
    case m: ActivityCommand => ACTIVITY_COMMAND
  }
}
