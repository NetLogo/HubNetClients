import org.nlogo.api._
import org.nlogo.api.Syntax._

object HubNetClientExtension {
  var client: Option[BasicClient] = None
  def connect(user:String, ip:String, port:Int){
    if(client.isDefined) sys.error("already connected. use disconnect first.")
    client = Some(BasicClient(user, "COMPUTER", ip, port))
  }
  def disconnect(){ client.foreach(_.close("feel like it.")) }
  def send(widgetName:String, newValue:AnyRef) {
    if(!client.isDefined) sys.error("not connected")
    client.foreach( _.sendActivityCommand("Button", widgetName, newValue))
  }
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
  override def getSyntax = commandSyntax(Array(TYPE_STRING, TYPE_STRING, TYPE_NUMBER))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.connect(args(0).getString, args(1).getString, args(2).getIntValue)
  }
}

class Disconnect extends DefaultCommand {
  override def getSyntax = commandSyntax(Array())
  def perform(args: Array[Argument], context: Context){ HubNetClientExtension.disconnect() }
}

class Send extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(TYPE_STRING, TYPE_WILDCARD))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.send(args(0).getString, args(1).get)
  }
}

class ClickButton extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(TYPE_STRING))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.send(args(0).getString, false.asInstanceOf[AnyRef])
  }
}