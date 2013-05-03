#include <model3d.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>

Model3D::Model3D()
{
  layers = (Layer **)0;
  nLayers = 0;
  logmsg = printf;
  memset(lights,0,sizeof(Light *)*MAX_LIGHTS);
  nLights = 0;
  return;
} // end of constructor

Model3D::~Model3D()
{
  for(int i=0;i<nLayers;i++) {
    if(layers[i]->vertices)
      free(layers[i]->vertices);
    if(layers[i]->facets)
      free(layers[i]->facets);
    if(layers[i]->facetIdx)
      free(layers[i]->facetIdx);
    free(layers[i]);
  }
  if(nLayers)
    free(layers);
  for(int i=0;i<MAX_LIGHTS;i++) 
    if(lights[i]) free(lights[i]);
  
  return;
} // end of destructor 

const char *Model3D::header(void)
{
  static char head[] = "Model3DSerialize";
  return head;
} // end of header

void Model3D::setlog(int (*setlog)(const char *,...))
{
  logmsg = setlog;
  return;
} // end of setlog

int Model3D::serialize(void **mem, int &len)
{
  // First, calculate the size of the
  // memory that we need to allocate
  len = 0;
  len += (int) strlen(header());
  len += sizeof(int);
  for(int i=0;i<nLayers;i++) {
    len += sizeof(Layer);
    len += sizeof(Vector)*layers[i]->nVertices;
    len += sizeof(Facet)*layers[i]->nFacets;
    len += sizeof(FacetIdx)*layers[i]->nFacetIdx;
  }
  len += sizeof(int)*2+sizeof(Vector)*2;
  len += sizeof(Light)*nLights;
  
  unsigned char *arr = (unsigned char *)
      malloc(sizeof(char)*len);
  unsigned char *s = arr;
  strcpy((char *)s,header());
  s += strlen(header());
  ((int *)s)[0] = nLayers;
  s += sizeof(int);
  for(int i=0;i<nLayers;i++) {
    memcpy(s,layers[i],sizeof(Layer));
    s += sizeof(Layer);
    if(layers[i]->nVertices) {
      memcpy(s,layers[i]->vertices,
             layers[i]->nVertices*sizeof(Vector));
      s += layers[i]->nVertices*sizeof(Vector);
    }
    if(layers[i]->nFacets) {
      memcpy(s,layers[i]->facets,
             layers[i]->nFacets*sizeof(Facet));
      s += layers[i]->nFacets*sizeof(Facet);
    }
    if(layers[i]->nFacetIdx) {
      memcpy(s,layers[i]->facetIdx,
             layers[i]->nFacetIdx*sizeof(FacetIdx));
      s += layers[i]->nFacetIdx*sizeof(FacetIdx);
    }
  }
  ((int *)s)[0] = nLights;
  s += sizeof(int);
  for(int i=0;i<nLights;i++) {
    memcpy(s,lights[i],sizeof(Light));
    s += sizeof(Light);
  }
  ((int *)s)[0] = (int) useCam;
  s += sizeof(int);
  memcpy(s,camPos,sizeof(Vector));
  s += sizeof(Vector);
  memcpy(s,camTarget,sizeof(Vector));
  s += sizeof(Vector);
  
  *mem = arr;  
  return 0;
} // end of serialize

const char *Model3D::model_type()
{
  static char nm[] = "Unknown";
  return nm;
} // end of type

Model3D *Model3D::unserialize(void *mem)
{
  Model3D *model = new Model3D;
  unsigned char *s = (unsigned char *)mem;
  
  // Do we have a valid file?
  if(strncmp((char *)s,header(),strlen(header()))) {
    delete model;
    return ((Model3D *)0);
  }
  s += strlen(header());
  model->nLayers = ((int *) s)[0];
  s += sizeof(int);
  if(model->nLayers)
    model->layers = (Layer **)malloc(sizeof(Layer *)*model->nLayers);
  else
    model->layers = (Layer **) 0;
  for(int i=0;i<model->nLayers;i++) {
    Layer *layer = (Layer *)malloc(sizeof(Layer));
    memcpy(layer,s,sizeof(Layer));
    s += sizeof(Layer);
    if(layer->nVertices) {
      layer->vertices = (Vector *)malloc(sizeof(Vector)*layer->nVertices);
      memcpy(layer->vertices,s,sizeof(Vector)*layer->nVertices);
      s += sizeof(Vector)*layer->nVertices;
    }
    else
      layer->vertices = (Vector *)0;
    if(layer->nFacets) {
      layer->facets = (Facet *)malloc(sizeof(Facet)*layer->nFacets);
      memcpy(layer->facets,s,sizeof(Facet)*layer->nFacets);
      s += sizeof(Facet)*layer->nFacets;
    }
    else
      layer->facets = (Facet *)0;
    if(layer->nFacetIdx) {
      layer->facetIdx = (FacetIdx *)malloc(sizeof(FacetIdx)*layer->nFacetIdx);
      memcpy(layer->facetIdx,s,sizeof(FacetIdx)*layer->nFacetIdx);
      s += sizeof(FacetIdx)*layer->nFacetIdx;
    }
    else
      layer->facetIdx = (FacetIdx *)0;
    model->layers[i] = layer;
  }
  model->nLights = ((int *)s)[0];
  s += sizeof(int);
  for(int i=0;i<model->nLights;i++) {
    Light *light = (Light *)malloc(sizeof(Light));
    memcpy(light,s,sizeof(Light));
    s += sizeof(Light);
    model->lights[i] = light;
  }
  model->useCam = (bool) ((int *)s)[0];
  s += sizeof(int);
  memcpy(model->camPos,s,sizeof(Vector));
  s += sizeof(Vector);
  memcpy(model->camTarget,s,sizeof(Vector));       
  
  return model;
} // end of unserialize