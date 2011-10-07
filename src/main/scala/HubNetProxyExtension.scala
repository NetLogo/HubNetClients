import org.nlogo.api._
import org.nlogo.api.Syntax._

object HubNetProxyExtension {
  def start(port:Int)= {}
  def stop() = {}
}

class HubNetProxyExtension extends DefaultClassManager {
  def load(manager: PrimitiveManager) {
    manager.addPrimitive("start", new Start)
    manager.addPrimitive("stop", new Stop)
  }
}

class Start extends DefaultCommand {
  override def getSyntax = commandSyntax(Array(TYPE_NUMBER))
  def perform(args: Array[Argument], context: Context){
    HubNetProxyExtension.start(args(0).getIntValue)
  }
}

class Stop extends DefaultCommand {
  override def getSyntax = commandSyntax(Array())
  def perform(args: Array[Argument], context: Context){ HubNetProxyExtension.stop() }
}
