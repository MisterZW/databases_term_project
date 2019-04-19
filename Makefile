JFLAGS = -g
JC = javac
JVM = java
.SUFFIXES: .java .class
.java.class:
	$(JC) $(JFLAGS) $*.java

CLASSES = \
	src/FlipTable.java \
	src/FlipTableConverters.java \
	src/ScriptRunner.java \
	src/ExpressRailway.java

MAIN = src/ExpressRailway

default: classes

classes: $(CLASSES:.java=.class)

run: $(MAIN).class
	$(JVM) $(MAIN)

clean:
	$(RM) src/*.class
