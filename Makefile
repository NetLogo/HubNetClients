ifeq ($(origin NETLOGO), undefined)
  NETLOGO=../..
endif

ifeq ($(origin SCALA_HOME), undefined)
  SCALA_HOME=../..
endif

SRCS=$(wildcard src/main/scala/*.scala)

all: compile hubnet-proxy.jar hubnet-client.jar

compile:
	mkdir -p classes
	$(SCALA_HOME)/bin/scalac -deprecation -unchecked -encoding us-ascii -classpath $(NETLOGO)/NetLogo.jar -d classes $(SRCS)

hubnet-proxy.jar: $(SRCS) manifests/proxy.txt Makefile
	jar cmf manifests/proxy.txt hubnet-proxy.jar -C classes .

hubnet-client.jar: $(SRCS) manifests/client.txt Makefile
	jar cmf manifests/client.txt hubnet-client.jar -C classes .

