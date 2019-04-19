JFLAGS = -cp
JC = javac
JVM = java
.SUFFIXES: .java .class
.java.class:
	$(JC) $*.java

JARS = \
	postgresql-42.1.3.jre6.jar:. \

CLASSES = \
	src/FlipTable.java \
	src/FlipTableConverters.java \
	src/ScriptRunner.java \
	src/ExpressRailway.java

MAIN = src/ExpressRailway

default: classes

classes: $(CLASSES:.java=.class)

run:  $(MAIN).class
	$(JVM) $(JFLAGS) $(JARS) $(MAIN)

clean:
	$(RM) src/*.class
