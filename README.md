# HubNet Clients

  This project contains examples of how to create NetLogo HubNet clients in various programming languages.

## Contents

 * src/main/java/HubNetJavaClient.java

 A simple example of how to build your own HubNet client in Java, complete with lots and lots of comments.

 * lib/NetLogo.jar

  Actually, right now this file isn't available. I would check it in, but I don't want to use up my space. The lite jar is here: http://ccl.northwestern.edu/netlogo/5.0beta2/NetLogoLite.jar. For beta3, NetLogo.jar will be right next to the lite jar, and I'll set up sbt to have it as a managed dependency. 

 * bin/sbt* 

  The sbt jar and the launch script for it. Sbt is the build tool I use here. To run it, just do: 
  ./bin/sbt

## Instructions

    ./bin/sbt
    > update   ;; only has to be done once, but won't work until after NetLogo 5.0beta3.
    > compile  ;; compiles the code (optional, because run will compile automatically)
    > run      ;; will run HubNetJavaClient.main, currently. 

## Terms of Use

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png)](http://creativecommons.org/publicdomain/zero/1.0/)

These sample HubNet clients are the public domain.  To the extent possible under law, Uri Wilensky has waived all copyright and related or neighboring rights.
