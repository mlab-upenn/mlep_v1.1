#ifndef _DXF_H_
#define _DXF_H_


typedef enum {
  UNKNOWN = -1,
  LAYER=0,
  VERTEX=1,
  THREE_D_FACE=2,
  NSECTIONS=3
} SectionType;

#include <model3d.h>

class DXF;
typedef int (DXF::*SectionFunc)(int token, char *line);
typedef int (DXF::*SectionEndFunc)(void);

class DXF : public Model3D
{
public:
  DXF(const char *filename=0);
  virtual ~DXF();
  
  int read_file(const char *filename);

  const char *model_type() {
    static char nm[] = "DXF";
    return nm;
  }
  
protected:

  
  // Functions for the layer handling
  Layer *curLayer;
  int add_layer(void);
  int create_current_layer(char *name = (char *)0);
  
  Layer *get_layer(const char *layer_name);
  
  // Functions for vertex handling
  Vector curVertex;
  Facet  curFacet;   
  FacetIdx curFacetIdx;
  int    curVType;
  char   curVLayer[64];
  int add_vertex(void);
  int add_facet(void);
  int add_facetidx(void);  
  
  
  int (*logmsg)(const char *,...);

  SectionType get_section(char *);
  
  // These are called to read in a section
  int vertexFunc(int token, char *line);
  int layerFunc(int token, char *line);
  int face3dFunc(int token, char *line);
  
  // These are called when a seciton is finished being 
  // read in
  int vertexEndFunc();
  int layerEndFunc();
  int face3dEndFunc();
  
  static SectionFunc sectionFuncs[NSECTIONS];
  static SectionEndFunc sectionEndFuncs[NSECTIONS];
  
  static const RGB colorTable[256];
    
}; // end of DXF class definition
  

#endif
