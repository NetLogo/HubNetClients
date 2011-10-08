import org.nlogo.api._
import org.nlogo.api.Syntax._
import org.nlogo.api.ScalaConversions._

object HubNetClientExtension {
  var client: Option[BasicClient] = None
}

class HubNetClientExtension extends DefaultClassManager {
  def load(manager: PrimitiveManager) {
    manager.addPrimitive("connect", new Connect)
    manager.addPrimitive("disconnect", new Disconnect)
    manager.addPrimitive("send", new Send)
  }
}

class Connect extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(StringType, StringType, NumberType))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.client match {
      case None => Some(
        try HubNetClientExtension.client = Some(BasicClient(
          userId=args(0).getString, clientType="COMPUTER",
          ip = args(1).getString, port = args(2).getIntValue))
        catch {
          case t => t.printStackTrace(); throw t
        }
      )
      case _ => sys.error("already connected. use disconnect first.")
    }
  }
}

class Disconnect extends DefaultCommand {
  override def getSyntax = commandSyntax(Array[Int]())
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.client match {
      case Some(client) =>
        client.close("feel like it.")
      case _ =>
    }
  }
}

class Send extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(StringType, WildcardType))
  def perform(args: Array[Argument], context: Context){
    HubNetClientExtension.client match {
      case Some(client) => client.sendActivityCommand(args(0).getString, args(1).get)
      case _ => sys.error("not connected")
    }
  }
}
