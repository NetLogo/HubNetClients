import org.nlogo.api._
import org.nlogo.api.Syntax._
import org.nlogo.api.ScalaConversions._

object HubNetClientExtension {
  var client: Option[BasicClient] = None
  def sendActivityCommand(tag:String, payload:AnyRef) = client match {
    case Some(client) => client.sendActivityCommand(tag, payload)
    case _ => sys.error("not connected")
  }
  def connect(userId:String, ip:String, port:Int) = client match {
    case None => Some(
      try client = Some(BasicClient(userId, "COMPUTER", ip, port))
      catch { case t => t.printStackTrace(); throw t }
    )
    case _ => sys.error("already connected. use disconnect first.")
  }
  def disconnect() = client.foreach(_.close("feel like it"))
}

class HubNetClientExtension extends DefaultClassManager {
  def load(manager: PrimitiveManager) {
    manager.addPrimitive("connect", new Connect)
    manager.addPrimitive("disconnect", new Disconnect)
    manager.addPrimitive("send", new Send)
    manager.addPrimitive("click-button", new ClickButton)
  }
}

class Connect extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(StringType, StringType, NumberType))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.connect(args(0).getString, args(1).getString, args(2).getIntValue)
  }
}

class Disconnect extends DefaultCommand {
  override def getSyntax = commandSyntax(Array[Int]())
  def perform(args: Array[Argument], context: Context){ HubNetClientExtension.disconnect() }
}

class Send extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(StringType, WildcardType))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.sendActivityCommand(args(0).getString, args(1).get)
  }
}

class ClickButton extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(StringType))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.sendActivityCommand(args(0).getString, false.asInstanceOf[AnyRef])
  }
}

