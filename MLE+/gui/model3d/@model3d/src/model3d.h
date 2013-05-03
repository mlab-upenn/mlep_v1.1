#ifndef _MODEL3D_H_
#define _MODEL3D_H_

typedef float Vector[3];
typedef int FacetIdx[4];
typedef Vector Facet[4];
typedef float RGB[3];

typedef struct {
  FacetIdx *facetIdx;
  int nFacetIdx;
  Facet *facets;
  int nFacets;
  Vector *vertices;
  int nVertices;
  char name[64];
  RGB diffuse;
  RGB ambient;
  RGB specular;
  float transparency;
  float shininess;
  float shinystrength;
} Layer;    

typedef struct {
  Vector pos;
  Vector dir;
}Light;

#define MAX_LIGHTS 10

class Model3D 
{
  public:
    Model3D();
    virtual ~Model3D();
    
    Layer **layers;
    int    nLayers;

    virtual void setlog(int (*setlog)(const char *,...));    
  
    // This must be overloaded with a function
    // that returns the model type
    virtual const char *model_type();
  
    int nLights;
    Light *lights[MAX_LIGHTS];
        
    // camera position & direction
    // if defined in the file.
    Vector camPos;
    Vector camTarget;
    bool   useCam;
  
    static const char *header();
    int serialize(void **mem, int &len);
    static Model3D *unserialize(void *mem);
    
  protected:
    
    int (*logmsg)(const char *,...);
}; // end of Model3D

#endif
