#include <dxf.h>

#if !defined(WIN32)
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#else
#include <fstream>
#endif

#include <dxfctable.h>

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

#define LALLOC 1000
#define FALLOC 10000
#define VALLOC 10000



SectionFunc DXF::sectionFuncs[NSECTIONS] = {
  &DXF::layerFunc,
  &DXF::vertexFunc,
  &DXF::face3dFunc
};

SectionEndFunc DXF::sectionEndFuncs[NSECTIONS] = {
  &DXF::layerEndFunc,
  &DXF::vertexEndFunc,
  &DXF::face3dEndFunc
};

DXF::DXF(const char *filename)
  : Model3D()
{
  curLayer = (Layer *)0;
  curFacet[0][0] = curFacet[0][1] = curFacet[0][2] = -1E9;
  curFacet[1][0] = curFacet[1][1] = curFacet[1][2] = -1E9;
  curFacet[2][0] = curFacet[2][1] = curFacet[2][2] = -1E9;
  curFacet[3][0] = curFacet[3][1] = curFacet[3][2] = -1E9;
  curVLayer[0] = '\0';
  if(!filename)
    return;
  
  read_file(filename);
  return;
} // end of constructor

DXF::~DXF(void)
{
  return;
}  // end of destructor

SectionType DXF::get_section(char *line)
{
  SectionType section = UNKNOWN;
  for(unsigned int i=0;i<strlen(line);i++)
    line[i] = tolower(line[i]);
  
  if(!strncmp(line, "vertex",6))
    section = VERTEX;
  else if(!strncmp(line,"layer",6)) 
    section = LAYER;
  else if(!strncmp(line, "3dface",6))
    section = THREE_D_FACE;
  
  return section;
} // end of get_section;

int DXF::read_file(const char *filename)
{
#if !defined(WIN32)
  // This is faster than standard C++ I/O functions
  int fd = open(filename, O_RDONLY);
  if(fd == -1) {
    logmsg("Cannot open file: %s\n",filename);
    return -1;
  }
  struct stat buf;
  fstat(fd,&buf);
  char *rawlines = new char[buf.st_size+1];
  read(fd, rawlines, sizeof(char)*buf.st_size);
  close(fd);
  int fsize = buf.st_size;
#else
  // In windows, use the standard C++ I/O
  std::ifstream f;
  f.open(filename);
  if(!f.is_open()) {
    logmsg("Cannot open file: %s\n",filename);
    return -1;
  }
  f.seekg(0,std::ios::end);
  int fsize = f.tellg();
  f.seekg(0,std::ios::beg);
  char *rawlines = new char[fsize+1];
  f.read(rawlines, sizeof(char)*fsize);
  rawlines[fsize] = '\0';
  f.close();
#endif

  char *s1,*s2;
  char *tokline = rawlines;
  char *valline;
  SectionType section = UNKNOWN;
  
  int token=0;
  while(tokline < rawlines + fsize) {
    // Extract and isolate the token & value line
    s1 = strstr(tokline,"\n");
    if(!s1) break;
    *s1 = '\0';
    valline = s1 + 1;
    if(valline >= rawlines+fsize) break;
    s1 = strstr(valline, "\n");
    if(s1) *s1 = '\0';
    
    // Get the token
    token = atoi(tokline);
    
    // This might be a DOS text file
    // If so, we must remove the carriage
    // returns
    s2 = strstr(valline,"\r");
    if(s2) *s2 = '\0';
    
    // Are we starting a new section?
    if(token == 0) {
      // End the old section
      if(section != UNKNOWN) 
        (this->*sectionEndFuncs[section])();
      section = get_section(valline);
    }
    // Continue with the current section
    else {
      if(section != UNKNOWN)
        (this->*sectionFuncs[section])(token,valline);
    } 
    // Go on to the next token/value pair
    tokline = s1+1;
  }

  // Do we have to do one last ending function?
  if(token!=0 && section != UNKNOWN)
    (this->*sectionEndFuncs[section])();
  
  delete[] rawlines;
  return 0;
} // end of read_file

int DXF::vertexFunc(int token, char *line)
{
  char *s = (char *)0;
  switch(token) {
    // The X,Y,Z locations of a vertex
    case 10:
      curVertex[0] = (float) atof(line);
      break;
    case 20:
      curVertex[1] = (float) atof(line);
      break;
    case 30:
      curVertex[2] = (float) atof(line);
      break;
    //  Is this a vertex or a facet index
    case 70:
      curVType = atoi(line);
      break;
    // The 3 or 4 indices that define a facet
    case 71:
      curFacetIdx[0] = atoi(line);
      break;
    case 72:
      curFacetIdx[1] = atoi(line);
      break;
    case 73:
      curFacetIdx[2] = atoi(line);
      break;
    case 74:
      curFacetIdx[3] = atoi(line);
      break;
    // The layer associated with the facet
    case 8:
      memset(curVLayer,0,64);
      s = line;
      while(*s == ' ' || *s == '\t') s++;
      for(unsigned int i=0;i<strlen(s);i++) {
        if(s[i] == ' ' || s[i] == '\t')  
          break;
        curVLayer[i] = s[i];
      }
      break;
    default:
      break;
  }
  return 0;
} // end of vertexFunc

int DXF::add_vertex(void)
{
  if(curVLayer[0] == '\0')
    return -1;
  
  Layer *layer = get_layer(curVLayer);
  if(!layer) {
    create_current_layer(curVLayer);
    add_layer();
    layer = curLayer;
  }
  if(layer->nVertices == 0)
    layer->vertices = (Vector *)malloc(sizeof(Vector)*VALLOC);
  else if(layer->nVertices % VALLOC == 0)
    layer->vertices = (Vector *)
        realloc(layer->vertices,sizeof(Vector)*(layer->nVertices+VALLOC));
  
  memcpy(layer->vertices[layer->nVertices++],curVertex,sizeof(Vector));
  
  return 0;
} // end of add_vertex 

int DXF::add_facetidx(void)
{
  if(curVLayer[0] == '\0')
    return -1;
  
  Layer *layer = get_layer(curVLayer);
  if(!layer) {
    create_current_layer(curVLayer);
    add_layer();
    layer = curLayer;
  }
  
  if(layer->nFacetIdx == 0)
    layer->facetIdx = (FacetIdx *)malloc(sizeof(FacetIdx)*FALLOC);
  else if(layer->nFacetIdx%FALLOC == 0)
    layer->facetIdx = (FacetIdx *)
        realloc(layer->facetIdx,sizeof(FacetIdx)*(layer->nFacetIdx+FALLOC));
  
  memcpy(layer->facetIdx[layer->nFacetIdx++],curFacetIdx,sizeof(FacetIdx));
  
  return 0;
} // end of add_facetidx

int DXF::add_facet(void)
{
  if(!curLayer)
    return -1;

  if(curLayer->nFacets == 0)
    curLayer->facets = (Facet *)malloc(sizeof(Facet)*FALLOC);
  else if(curLayer->nFacets % FALLOC == 0)
    curLayer->facets = (Facet *)
      realloc(curLayer->facets,sizeof(Facet)*(curLayer->nFacets+FALLOC));
  memcpy(curLayer->facets[curLayer->nFacets++],curFacet,sizeof(Facet));
  return 0;
} // end of add_facet

int DXF::vertexEndFunc(void)
{
  if(curVType == 192)
    add_vertex();
  else if(curVType == 128)
    add_facetidx();
  
  curFacetIdx[0] = curFacetIdx[1] = curFacetIdx[2] = curFacetIdx[3] = -1;
  curVLayer[0] = '\0';
  return 0;
}

int DXF::layerFunc(int token, char *line)
{
  if(curLayer==0 ) 
    create_current_layer();
 
  char *s = (char *)0;
  switch(token) {
    // Layer name
    case 2:
      memset(curLayer->name,0,64);
      s = line;
      while(*s == '\t' || *s == ' ') s++;
      for(unsigned int i=0;i<strlen(s);i++) {      
        if(s[i] == ' ' || s[i] == '\t') break;
          curLayer->name[i] = s[i];
      }
      break;
    case 62:
    {
      // Set the ambient & diffuse colors to this colors
      int color = atoi(line);
      curLayer->ambient[0] = colorTable[color-1][0];
      curLayer->ambient[1] = colorTable[color-1][1];
      curLayer->ambient[2] = colorTable[color-1][2];
      memcpy(curLayer->diffuse,curLayer->ambient,sizeof(RGB));
      memcpy(curLayer->specular,curLayer->ambient,sizeof(RGB));
      break;
    }
    default:
      break;
  }
  return 0;
} // end of layerFunc

int DXF::create_current_layer(char *name)
{
  curLayer = (Layer *)malloc(sizeof(Layer));
  curLayer->nVertices = 0;
  curLayer->nFacets = 0;
  curLayer->nFacetIdx = 0;
  curLayer->ambient[0] = curLayer->ambient[1] = curLayer->ambient[2] = 0.5f;
  memcpy(curLayer->diffuse,curLayer->ambient,sizeof(RGB));
  memcpy(curLayer->specular,curLayer->ambient,sizeof(RGB));
  curLayer->shininess = curLayer->shinystrength = 0.0f;
  curLayer->transparency = 0.0f;
  
  curLayer->name[0] = '\0';
  curLayer->facetIdx = (FacetIdx *)0;
  curLayer->facets = (Facet *)0;
  curLayer->vertices = (Vector *)0;
 
  if(name)
    strcpy(curLayer->name,name);
  return 0;
} // end of create_layer

int DXF::add_layer(void)
{
  if(curLayer == (Layer *)0)
     return 0;
  
  // Make sure we have enough memory
  if(!layers) 
    layers = (Layer **)malloc(sizeof(Layer *)*LALLOC);
  else if(nLayers > 0 && nLayers%LALLOC==0) 
    layers = (Layer **)realloc(layers,sizeof(Layer *)*(nLayers+LALLOC));
  
  // Add on to the end of the list
  layers[nLayers++] = curLayer;
  return 0;
} // end of add_layer

Layer *DXF::get_layer(const char *layerName)
{
  for(int i=0;i<nLayers;i++) {
    if(!strcmp(layers[i]->name,layerName))
      return layers[i];
  }
  return (Layer *)0;
} // end of get_layer;


int DXF::layerEndFunc(void)
{
  if(add_layer()) return -1;
  curLayer = (Layer *)0;
  return 0;
} // end of layerEndFunc

int DXF::face3dFunc(int token, char *line)
{
  char *s;
  switch(token) {
    case 2:
    case 8:      char name[64];
      memset(name,0,64);
      s = line;
      while(*s == ' ' || *s == '\t') *s++;
      for(unsigned int i=0;i<strlen(s);i++) {
        if(s[i] == ' ' || s[i] == '\t') break;
        name[i] = s[i];
      }
      curLayer = get_layer(name);
      if(!curLayer) {
        create_current_layer(name);
        add_layer();
      }
      break;
    case 10:
      curFacet[0][0] = (float) atof(line);
      break;
    case 20:
      curFacet[0][1] = (float) atof(line);
      break;
    case 30:
      curFacet[0][2] = (float) atof(line);
      break;
    case 11:
      curFacet[1][0] = (float) atof(line);
      break;
    case 21:
      curFacet[1][1] = (float) atof(line);
      break;
    case 31:
      curFacet[1][2] = (float) atof(line);
      break;
    case 12:
      curFacet[2][0] = (float) atof(line);
      break;
    case 22:
      curFacet[2][1] = (float) atof(line);
      break;
    case 32:
      curFacet[2][2] = (float) atof(line);
      break;
    case 13:
      curFacet[3][0] = (float) atof(line);
      break;
    case 23:
      curFacet[3][1] = (float) atof(line);
      break;
    case 33:
      curFacet[3][2] = (float) atof(line);
      break;

   default:
      break;
  }
  return 0;
} // end of face3dFunc

int DXF::face3dEndFunc(void)
{
  if(add_facet())
    return -1;
  curLayer = (Layer *)0;
  curFacet[0][0] = curFacet[0][1] = curFacet[0][2] = -1E9f;
  curFacet[1][0] = curFacet[1][1] = curFacet[1][2] = -1E9f;
  curFacet[2][0] = curFacet[2][1] = curFacet[2][2] = -1E9f;
  curFacet[3][0] = curFacet[3][1] = curFacet[3][2] = -1E9f;
  return 0;
} // end of face3dEndFunc

#ifdef _TEST_
int main(int argc, char *argv[])
{
  DXF dxf("/home/smichael/track3d/models/tacoma.dxf");
  return 0;
} // end of main
#endif
