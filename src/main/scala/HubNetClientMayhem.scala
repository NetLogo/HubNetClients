object HubNetClientMayhem {
  def main(args: Array[String]) {
    val random = new util.Random()
    val clients = for (i <- 1 to 100)
      yield new BasicClient(userId=i.toString, clientType="ANDROID")
    val buttons = clients(0).interfaceSpec
    Thread.sleep(10000)
    while(true){
      for( c <- clients )
        c.sendActivityCommand(buttons(random.nextInt(4)).toString, false)
      Thread.sleep(200)
    }
  }
}
