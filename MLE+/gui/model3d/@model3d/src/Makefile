TARGET = ../model3d.mexglx
TARGET2 = ../serialize.mexglx
SOURCES = dxf.cpp mexfunction.cpp model3d.cpp c3ds.cpp
MATDIR = /usr/local/matlab14
#CXX = icpc
#CXXFLAGS = -gcc-version=320 -cxxlib-gcc=/usr/local/gcc-3.2.3 -O3 -xN -w1 
CXX = /usr/local/gcc-3.2.3/bin/g++
CXXFLAGS = -O3 -Wall
LIBDIR = -L$(MATDIR)/bin/glnx86 
LIBS = -lmat -lmex -lmx 
INCDIR = -I. -I$(MATDIR)/extern/include

all : $(TARGET) $(TARGET2)

$(TARGET2) : serialize.o model3d.o 
	$(CXX) $(CXXFLAGS) $(LIBDIR) $(LIBS) -shared $^ -o $@

$(TARGET) : $(patsubst %.cpp,%.o,$(SOURCES))
	$(CXX) $(CXXFLAGS) $(LIBDIR) $(LIBS) -shared $^ -o $@

%.o : %.cpp %.h
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $<

%.o : %.cpp
	$(CXX) $(CXXFLAGS) $(INCDIR) -c $<

clean : 
	rm -rf $(TARGET) $(patsubst %.cpp,%.o,$(SOURCES)) serialize.o
