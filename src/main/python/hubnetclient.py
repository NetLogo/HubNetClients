from socket import *
from struct import *
from random import *
from time import *

client = socket(AF_INET,SOCK_STREAM)
client.connect(("localhost", 9173))

def writeInt(i):
  client.send(pack('!i', i))

def writeBoolean(b):
  client.send(pack('!b', b))

def writeDouble(d):
  client.send(pack('!d', d))

def writeString(s):
  writeInt(len(s))
  client.send(s)

def writeAny(a):
  if isinstance(a, str):
    writeInt(0)
    writeString(a)
  elif isinstance(a, float):
    writeInt(1)
    writeDouble(a)
  elif isinstance(a, bool):
    writeInt(2)
    writeBoolean(a)

def sendProtocol():
  client.send("Binary  ")

def handshake(userId, clientType):
  sendProtocol()
  sendVersionMessage("NetLogo 5.0beta4")
  sendEnterMessage(userId, clientType)
  
def sendEnterMessage(userId, clientType):
  writeInt(12)
  writeString(userId)
  writeString(clientType)

def sendActivityMessage(typ, name, newVal):
  writeInt(13) # 13 is the id of ActivityMessage
  writeString(typ)
  writeString(name)
  writeAny(newVal)

def pressButton(name):
  sendActivityMessage("Button", name, False)

def sendVersionMessage(v):
  writeInt(15) # 15 is the id of VersionMessage
  writeString(v)

def sendExitMessage(reason):
  writeInt(2)
  writeString(reason)

def sendDisableView():
  writeInt(4)

def example():
  handshake("josh", "COMPUTER")
  buttons = ["up", "down", "left", "right"]
  while True:
    pressButton(buttons[randint(0,3)])
    sleep(1)
  #sendActivityMessage("Slider", "my-slider", 56.5)
  #sendActivityMessage("Switch", "my-switch", False)
  #sendActivityMessage("Chooser", "my-chooser", "hello world")
  sendExitMessage("Feel like it")

example()

