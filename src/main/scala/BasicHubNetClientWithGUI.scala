import java.awt.event.{WindowAdapter, WindowEvent, ActionEvent, ActionListener}
import javax.swing.{JFrame, JButton, JLabel, JTextField, BoxLayout, JPanel}

/**
 * This class demonstrates (in a very quick and dirty way) how to
 * build a HubNet client with it's own GUI.
 *
 * As with the other examples in this project, the modified Template model is assumed.
 */
object BasicHubNetClientWithGUI{

  def main(args:Array[String]){ new ConnectionGUI().go() }

  /**
   * This class creates a window where the user can enter
   * username, ip, and port.
   * When they click Connect, a connection is attempted.
   * If it was successful, it hands the client over to the next class, ClientGUI.
   * If not, it prints out the error and does nothing.
   * The data can be reinput at that time.
   */
  class ConnectionGUI extends JFrame {
    getContentPane.add(new ConnectionPanel)
    this.addWindowListener(new WindowAdapter() {
      override def windowClosing(e: WindowEvent) {ConnectionGUI.this.dispose()}
    })
    def go() { pack(); setVisible(true) }

    class ConnectionPanel extends JPanel {
      private val name = new JTextField(20){ setText("robot") }
      private val ip = new JTextField(20){ setText("localhost") }
      private val port = new JTextField(20){ setText("9173") }
      setLayout(new BoxLayout(this, BoxLayout.Y_AXIS))
      def makePanel(name: String, tf: JTextField) = new JPanel() {add(new JLabel(name)); add(tf)}
      add(makePanel("Name:", name))
      add(makePanel("IP:  ", ip))
      add(makePanel("Port:", port))
      add(new JButton("Connect") {
        addActionListener(new ActionListener() {
          def actionPerformed(actionEvent: ActionEvent) {
            try {
              // the connection is attempted here. 
              val client = new BasicClient(name.getText, "ANDROID", ip.getText, port.getText.toInt)
              // if no error occured, then the connection was established.
              // hand the client over to the ClientGUI class.
              new ClientGUI(client).run()
              ConnectionGUI.this.dispose
            }
            catch { case e: Exception => e.printStackTrace; false }
          }
        })
      })
    }
  }

  /**
   * This very naive class that displays a client GUI.
   */
  class ClientGUI(client:BasicClient) {
    def run() = { new ClientFrame().go() }
    class ClientFrame extends JFrame {
      getContentPane.add(new ClientPanel)
      this.addWindowListener(new WindowAdapter() {
        override def windowClosing(e: WindowEvent) {
          client.close("Window closed.")
          ClientFrame.this.dispose()
        }
      })
      def go() { pack(); setVisible(true) }
      class ClientPanel extends JPanel {
        class MessageButton(message: String) extends JButton(message) {
          addActionListener(new ActionListener() {
            def actionPerformed(actionEvent: ActionEvent) {sendMessage(message)}
          })
        }

        /**
         * Here, GUI buttons are created for each of the buttons in the
         * Template model interface spec for ANDROID [up down left right].
         *
         * This would be the place where other widgets could be added
         * if other things were in the interfaceSpec, or where a developer
         * could parse NetLogo's interfaceSpec (if using clientType=COMPUTER)
         */
        for(b<-client.interfaceSpec) add(new MessageButton(b.toString))
      }
    }
    def sendMessage(message: String) {
      client.sendActivityCommand("Button", message, false.asInstanceOf[AnyRef])
    }
  }
}
