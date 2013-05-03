#include "c3ds.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(WIN32)
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <sys/types.h>
#else
#include <mex.h>
#include <fstream>
#endif

#define NALLOC 10000

//#define _DEBUG_

ChunkStruct C3DS::chunkStruct[] = 
{
  {0xafff,"Material",NULL},
  {0x4d4d,"Main Chunk",NULL},
  {0x3d3d,"Main Sub-Chunk",NULL},
  {0xa000,"Material Creation",&C3DS::read_0xa000_chunk},
  {0x4000,"Object Creation",&C3DS::read_0x4000_chunk},
  {0x4100,"TriFace Creation",NULL},
  {0x4110,"TriFace Vertices",&C3DS::read_0x4110_chunk},
  {0x4120,"TriFace Faces",&C3DS::read_0x4120_chunk},
  {0x4160,"Translation",&C3DS::read_0x4160_chunk},
  {0x4130,"TriFace List",&C3DS::read_0x4130_chunk},
  {0x4600,"Light Object",&C3DS::read_0x4600_chunk},
  {0x4610,"Light Target",&C3DS::read_0x4610_chunk},
  {0x4700,"Object Camera",&C3DS::read_0x4700_chunk},
  {0xa000,"Material Name",&C3DS::read_0xa000_chunk},
  {0xa010,"Ambient Color",&C3DS::read_0xa010_chunk},
  {0xa020,"Diffuse Color",&C3DS::read_0xa020_chunk},
  {0xa030,"Specular Color",&C3DS::read_0xa030_chunk},
  {0xa040,"Shininess",&C3DS::read_0xa040_chunk},
  {0xa041,"Shiny Strength",&C3DS::read_0xa041_chunk},
  {0xa050,"Transparency",&C3DS::read_0xa050_chunk}
 };

C3DS::C3DS(const char *filename)
  : Model3D()
{
  logmsg = printf;
  
  materials = (Material3DS **)0;
  nMaterials = 0;
  delLayer = (Layer *)0;
  curMaterial = (Material3DS *)0;
  curLight = (Light *)0;
  if (filename)
    read_file(filename);
}				// end of constructor

C3DS::~C3DS()
{
  for(int i=0;i<nMaterials;i++) 
    free(materials[i]);
  if(materials)
    free(materials);

}				// end of destructor


int C3DS::read_file(const char *filename)
{
#if !defined(WIN32)
  // Read in the file
  int fd = open(filename, O_RDONLY);
  struct stat buf;
  if(fd == -1) {
    logmsg("File not open: %s\n",filename);
    return -1;
  }
  fstat(fd,&buf);
  unsigned char *data = new unsigned char[buf.st_size+1];
  read(fd,data,buf.st_size);
  close(fd);
	int fsize = buf.st_size;
#else
	std::ifstream is(filename,std::ios::binary);
	if(is.is_open()==0) {
		logmsg("File not open: %s\n",filename);
		return -1;
	}
	is.seekg(0,std::ios::end);
	int fsize = is.tellg();
	is.seekg(0,std::ios::beg);
	unsigned char *data = new unsigned char[fsize+1];
	is.read((char *)data,fsize);
	is.close();
#endif
  // Walk through the file
  unsigned char *s = (unsigned char *)data;
  int nChunks = sizeof(chunkStruct)/sizeof(ChunkStruct);
  
  while(s < data + fsize) {
    unsigned short *chunkID = (unsigned short *)s;
    int *chunkLen = (int *) (s+sizeof(unsigned short));
    s += 6;
    
#ifdef _DEBUG_
    logmsg("chunkID = 0x%.4X :: length = %d\n",chunkID[0],chunkLen[0]);
#endif
    int i;
    // Look for a recognized chunk
    for(i=0;i<nChunks;i++) {
      if(chunkID[0] == chunkStruct[i].ID)
        break;
    }
    // If we have found a recognized chunk, run the
    // appropriate function
    if(i != nChunks) {
      if(chunkStruct[i].handler == NULL) 
        continue;
      else {
        // The function should return the number of bytes to skip
        // to get to the next chunkID
        int ret = (this->*chunkStruct[i].handler)(s,chunkLen[0]-6);
        // A negative return indicates an error
        if(ret < 0) {
          logmsg("Error reading chunk: 0x%.4X\n",chunkID[0]);
          return -1;
        }
        // iterate the position counter
        s += ret;
      }
    }
    // We have an unknown chunk, so skip it
    else 
      s += chunkLen[0] - 6;
  } // end of while
  
  if(delLayer) {
    delete_layer();
    delLayer = (Layer *)0;
  }
	delete[] data;
  return 0;
} // end of read_file


// This reads in a material
int C3DS::read_0xa000_chunk(byte *head, int len)
{
  // Create a new material in variable "curMaterial"  
  create_material();
  // Set the name of the material
  strncpy(curMaterial->name,(const char *)head,64);
  
  return (int) strlen((char *)head)+1;
} // end of read_a000_chunk

int C3DS::read_0x4160_chunk(byte *s, int len)
{
  float *rot = (float *)s;
  float *trans = (float *)(s+sizeof(float)*9);
  Vector tmp;
  
  // Note, we translate and then we rotate
  for(int vidx=0;vidx<curLayer->nVertices;vidx++) {
    tmp[0] = tmp[1] = tmp[2] = 0;
  
    // Do the matrix multiplication
    for(int i=0;i<3;i++) {
      tmp[i] = 0;
      for(int j=0;j<3;j++) {
        tmp[i] += rot[i*3+j]*(curLayer->vertices[vidx][j] + trans[j]);
      }
    }
  }   
  return len;
} // end of read_0x4160_chunk

int C3DS::read_0x4600_chunk(byte *s, int len)
{
  curLight = (Light *)malloc(sizeof(Light));
  for(int i=0;i<MAX_LIGHTS;i++) {
    if(!lights[i]) {
      lights[i] = curLight;
      break;
    }
  }
  memcpy(curLight->pos,s,sizeof(Vector));
  curLight->dir[0] = curLight->dir[1] = curLight->dir[2] = 0.0;
  return sizeof(Vector);
} // end of read_0x4600_chunk

int C3DS::read_0x4610_chunk(byte *s, int len)
{
  if(!curLight) return len;
  memcpy(curLight->dir,s,sizeof(Vector));
  return len;
} // end of read_0x4610_chunk

int C3DS::read_color(byte *s, RGB rgb)
{
  short *id = (short *)s;
  switch(id[0]) {
    case 0x0010:
    case 0x0013:
      memcpy(rgb,s+6,sizeof(float)*3);
      break;
    case 0x0011:
    case 0x0012:
      rgb[0] = (float) s[6];
      rgb[1] = (float) s[7];
      rgb[2] = (float) s[8];
      break;
    default:
      logmsg("Did not get a color\n");
      logmsg("Got 0x%0.4X\n",id[0]);
      return -1;
      break;
  }
  rgb[0] /= 256.0f;
  rgb[1] /= 256.0f;
  rgb[2] /= 256.0f;
  return 0;
} // end of read_color

int C3DS::read_number(byte *head, float &num)
{
  short *id = (short *)head;
  byte *s = head+6;
  switch(id[0]) {
    case 0x0030:
      num = (float) ((short *)s)[0];
      break;
    case 0x0031:
      num = ((float *)s)[0];
      break;
    default:
      logmsg("Did not get a number\n");
      logmsg("Got 0X%.4X\n",id[0]);
      return -1;
      break;
  }
  return 0;
} // end of read_number

int C3DS::read_0xa010_chunk(byte *head, int len)
{
  if(read_color(head,curMaterial->ambient)<0)
    return -1;
  return len;
}

int C3DS::read_0xa020_chunk(byte *head, int len)
{
  if(read_color(head, curMaterial->diffuse)<0)
    return -1;
  return len;
}

int C3DS::read_0xa030_chunk(byte *head, int len)
{
  if(read_color(head, curMaterial->specular)<0)
    return -1;
  return len;
}

int C3DS::read_0xa040_chunk(byte *head, int len)
{
  if(read_number(head,curMaterial->shininess)<0)
    return -1;
  return len;
}

int C3DS::read_0xa041_chunk(byte *head, int len)
{
  if(read_number(head,curMaterial->shinystrength)<0)
    return -1;
  return len;
} 

int C3DS::read_0xa050_chunk(byte *head, int len)
{
  if(read_number(head, curMaterial->transparency)<0)
    return -1;
  return len;
} 

#define LALLOC 1000
int C3DS::create_layer()
{
  if(!layers)
    layers = (Layer **)malloc(sizeof(Layer *)*LALLOC);
  else if(nLayers % LALLOC == 0)
    layers = (Layer **)
        realloc(layers,sizeof(Layer *)*(LALLOC+nLayers));
  
  // Create the current layer & add it to the end of the list
  curLayer = (Layer *)malloc(sizeof(Layer));
  curLayer->name[0] = '\0';
  curLayer->nFacetIdx  = curLayer->nVertices = 0;
  curLayer->vertices = (Vector *)0;
  curLayer->facetIdx = (FacetIdx *)0;
  curLayer->facets = (Facet *)0;
  curLayer->nFacets = 0;
  curLayer->ambient[0] = curLayer->ambient[1] = curLayer->ambient[2] = 0.0f;
  curLayer->diffuse[0] = curLayer->diffuse[1] = curLayer->diffuse[2] = 0.0f;
  curLayer->specular[0] = curLayer->specular[1] = 
      curLayer->specular[2] = 0.0f;
  curLayer->shininess = curLayer->shinystrength = 0.0f;
  curLayer->transparency = 0.0f;
  layers[nLayers++] = curLayer;
    
  return 0;
}

#define MALLOC 100
int C3DS::create_material()
{
  if(!materials)
    materials = (Material3DS **)malloc(sizeof(Material3DS *)*MALLOC);
  else if(nMaterials % MALLOC == 0)
    materials = (Material3DS **)
        realloc(materials,sizeof(Material3DS *)*(nMaterials+MALLOC));
  
  curMaterial = (Material3DS *)malloc(sizeof(Material3DS));
  curMaterial->name[0] ='\0';
  curMaterial->ambient[0] = curMaterial->ambient[1] = 
      curMaterial->ambient[2] = -1.0f;
  curMaterial->diffuse[0] = curMaterial->diffuse[1] = 
      curMaterial->diffuse[2] = -1.0f;
  curMaterial->specular[0] = curMaterial->specular[1] = 
      curMaterial->specular[2] = -1.0f;
  materials[nMaterials++] = curMaterial;
  return 0;
} // end of create_material

int C3DS::delete_layer()
{
  if(!delLayer) 
    return 0;
  
  int i;
  for(i=0;i<nLayers;i++) {
    if(layers[i] == delLayer)
      break;
  }
  
  if(i < nLayers) {
    for(int j=i;j<nLayers;j++) {
      layers[j] = layers[j+1];
    }
    nLayers--;
    if(delLayer->vertices) free(delLayer->vertices);
    if(delLayer->facets) free(delLayer->facets);
    if(delLayer->facetIdx) free(delLayer->facetIdx);
    free(delLayer);
  }
  
  return 0;
} // end of delete_layer

int C3DS::read_0x4000_chunk(byte *head, int len)
{
  if(delLayer)  {
    delete_layer();
    delLayer = (Layer *)0;
  }

  create_layer();  
  strncpy(curLayer->name,(char *)head,64);

  return (int) strlen((char *)head)+1;
} // end of read_0x400_chunk

int C3DS::apply_material(const char *matname)
{
  if(!curLayer) {
    logmsg("A layer has not been selected\n");
    return -1;
  }
  
  Material3DS *material = (Material3DS *)0;
  for(int i=0;i<nMaterials;i++) {
    if(!strcmp(matname,materials[i]->name)) {
      material = materials[i];
      break;
    }
  }
  if(!material) {
    logmsg("The material name is invalid\n");
    return -1;
  }
  
  memcpy(curLayer->ambient,material->ambient,sizeof(RGB));
  memcpy(curLayer->specular,material->specular,sizeof(RGB));
  memcpy(curLayer->diffuse,material->diffuse,sizeof(RGB));
  curLayer->shininess = material->shininess;
  curLayer->shinystrength = material->shinystrength;
  curLayer->transparency = material->transparency;
  
  return 0;
}

int C3DS::read_0x4130_chunk(byte *head, int len)
{
  char *mname = (char *)head;
  apply_material(mname);
  
  unsigned short *nfacet = (unsigned short *) (head+strlen(mname)+1);
  
  
  // If the material doesn't take up all the object, the current list of
  // triangles is divided up among multiple materials.  This is rare, but we
  // must divide the list up into multiple layers.  This is a royal pain, but
  // I think that I got it working.
  if(nfacet[0] != curLayer->nFacetIdx) {
    apply_material(mname);
    unsigned short *facets = (unsigned short *)(head+strlen(mname)+3);
    
    int *vidx = (int *)malloc(sizeof(int)*curLayer->nVertices);
    
    // Initialize all the new vertex indices to -1
    // indicating an invalid vertex for this layer
    for(int i=0;i<curLayer->nVertices;i++)
      vidx[i] = -1;
    
    // See which ones are used
    // and set them in an order    
    int nNewVertices = 0;
    // Note the offset of 1 -- MATLAB is one based, so the 
    // facetIDX variables are one based, but the 3DS file is 
    // 0 based, so we must offset
    for(int i=0;i<nfacet[0];i++) {     
      if(vidx[ curLayer->facetIdx[ facets[i] ][0] -1 ] == -1)
        vidx[ curLayer->facetIdx[ facets[i]] [0] -1 ] = nNewVertices++;
      
      if(vidx[ curLayer->facetIdx[ facets[i] ][1] -1 ] == -1)
        vidx[ curLayer->facetIdx[ facets[i] ][1] -1 ] = nNewVertices++;
      
      if(vidx[ curLayer->facetIdx[ facets[i] ][2] -1 ] == -1)
        vidx[ curLayer->facetIdx[ facets[i] ][2] -1 ] = nNewVertices++;
    }
    
    // Create  new layer
    Layer *layer = new Layer;
    memcpy(layer->ambient,curLayer->ambient,sizeof(RGB));
    memcpy(layer->specular,curLayer->specular,sizeof(RGB));
    memcpy(layer->diffuse,curLayer->diffuse,sizeof(RGB));    
    char lname[256];
    sprintf(lname,"%s_%s",curLayer->name,mname);
    strncpy(layer->name,lname,64);
    layer->shininess = curLayer->shininess;
    layer->shinystrength = curLayer->shinystrength;
    layer->transparency = curLayer->transparency;
    layer->facets = (Facet *)0;
    layer->nFacets = 0;
    layer->nVertices = nNewVertices;
    layer->vertices = (Vector *)malloc(sizeof(Vector)*nNewVertices);
    
    // Copy the used vertices to the new layer
    for(int i=0;i<curLayer->nVertices;i++) {
      if(vidx[i] != -1) 
        memcpy(layer->vertices[vidx[i]],curLayer->vertices[i],sizeof(Vector));
    }
    
    // Copy the used facet indices to the new layer, making sure that
    // they point to the new vertex indices and are 1 (not 0) based for
    // MATLAB
    layer->nFacetIdx = nfacet[0];
    layer->facetIdx = (FacetIdx *)malloc(sizeof(FacetIdx)*layer->nFacetIdx);
    for(int i=0;i<layer->nFacetIdx;i++) {
      layer->facetIdx[i][0] = vidx[curLayer->facetIdx[facets[i]][0]-1]+1;
      layer->facetIdx[i][1] = vidx[curLayer->facetIdx[facets[i]][1]-1]+1;
      layer->facetIdx[i][2] = vidx[curLayer->facetIdx[facets[i]][2]-1]+1;
      layer->facetIdx[i][3] = -1;
    }

    // Free indexing memory
    free(vidx);

    // Make sure the current "Meta" layer that holds
    // the multiple materials is set to be deleted
    // after the fact
    delLayer = curLayer;
    
    
    // Add the layer to the list
    if(nLayers % LALLOC == 0)
      layers = (Layer **)
          realloc(layers,sizeof(Layer *)*(LALLOC + nLayers));
    layers[nLayers++] = layer;
    
  } // Done subdividing layer
  
  return len;
} // end of read_0x4130_chunk

int C3DS::read_0x4120_chunk(byte *head, int len)
{
  // Read in some facets
  unsigned short *nFacetIdx = (unsigned short *)head;  
  
  if(!curLayer) {
    logmsg("Adding facets before defining a layer??\n");
    return -1;
  }
  if(!curLayer->facetIdx)
    curLayer->facetIdx = 
        (FacetIdx *)malloc(sizeof(FacetIdx)*nFacetIdx[0]);
  else 
    curLayer->facetIdx = (FacetIdx *)
        realloc(curLayer->facetIdx,
                sizeof(FacetIdx)*(nFacetIdx[0]+curLayer->nFacetIdx));
  
  unsigned short *fPtr = (unsigned short *) (head+2);
  for(int i=0;i<nFacetIdx[0];i++) {
    curLayer->facetIdx[curLayer->nFacetIdx+i][0] = fPtr[i*4]+1;
    curLayer->facetIdx[curLayer->nFacetIdx+i][1] = fPtr[i*4+1]+1;
    curLayer->facetIdx[curLayer->nFacetIdx+i][2] = fPtr[i*4+2]+1;
    curLayer->facetIdx[curLayer->nFacetIdx+i][3] = -1;
  }
  curLayer->nFacetIdx += nFacetIdx[0];
  
  return nFacetIdx[0]*8+ 2;
} // end of read_0x4120_chunk
  
int C3DS::read_0x4700_chunk(byte *s, int len)
{
  
  memcpy(camPos,s,sizeof(Vector));
  memcpy(camTarget,s+sizeof(Vector),sizeof(Vector));
  useCam = true;
  return len;
} // end of read_0x4700_chunk

int C3DS::read_0x4110_chunk(byte *s, int len)
{
  unsigned short *numVert = (unsigned short *)s;
  if(!curLayer) {
    logmsg("Adding vertices before defining a layer??\n");
    return -1;
  }
  if(!curLayer->vertices)
    curLayer->vertices = (Vector *)malloc(sizeof(Vector)*numVert[0]);
  else
    curLayer->vertices = (Vector *)
        realloc(curLayer->vertices,sizeof(Vector)*(numVert[0]+curLayer->nVertices));
  
  memcpy(curLayer->vertices+sizeof(Vector)*curLayer->nVertices,
         s+2,sizeof(Vector)*numVert[0]);
  curLayer->nVertices += numVert[0];

  return numVert[0]*sizeof(Vector)+2;
} // end of read_0x4110_chunk
  
  

#ifdef _TEST_

int main(int argc, char *argv[])
{
  C3DS *c3ds = new C3DS("/home/smichael/track3d/models/bellrang.3ds");
  //C3DS *c3ds = new C3DS("/home/smichael/4313.3ds");
  printf("nLayers = %d\n",c3ds->nLayers);
  delete c3ds;
  return 0;
};
#endif
