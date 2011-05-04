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

All contents © 2004-2011 Uri Wilensky.

The contents of this package may be freely copied, distributed, altered, or otherwise used by anyone for any legal purpose.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
