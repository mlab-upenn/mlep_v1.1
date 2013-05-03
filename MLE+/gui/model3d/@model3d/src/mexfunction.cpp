#include <mex.h>

#include <dxf.h>
#include <c3ds.h>

#include <string.h>
#include <ctype.h>

#if !defined(WIN32)
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#else
#include <fstream>
#endif

const char *fieldNames[] = {"filename","layers","type","campos","camtarget","lights"};
const char *lFieldNames[] = {
  "name","vertices","facetidx","facets",
  "ambient","diffuse","specular",
  "shininess","shinystrength","transparency"};
const char *lightFieldNames[] = {"pos","dir"};

typedef enum {
  TYPE_BAD = -1,
  TYPE_3DS = 0,
  TYPE_DXF = 1,
  TYPE_M3D = 2
}FileType;

static void make_class(mxArray **out, const mxArray *in)
{
  const mxArray *prhs[2];
  prhs[0] = in;
  prhs[1] = mxCreateString("model3d");
  mexCallMATLAB(1,out,2,(mxArray **)prhs,"class");
  return;
} // end of make_class

static FileType get_file_type(const char *filename)
{
  char lfilename[256];
  for(unsigned int i=0;i<strlen(filename);i++)
    lfilename[i] = tolower(filename[i]);

  if(strlen(lfilename)>4) {
    if(!strcmp(lfilename+strlen(lfilename)-4,".3ds"))
      return TYPE_3DS;
    if(!strcmp(lfilename+strlen(lfilename)-4,".dxf"))
      return TYPE_DXF;
    if(!strcmp(lfilename+strlen(lfilename)-4,".m3d"))
      return TYPE_M3D;
  }
  
  unsigned char data[256];
  memset(data,0,256);
#if !defined(WIN32)
  int fd  = open(filename,O_RDONLY);
  if(fd == -1)
    return TYPE_BAD;
  read(fd,data,strlen(Model3D::header()));
  close(fd);
#else
	std::ifstream is;
	is.open(filename,std::ios::binary);
	if(is.is_open()==0)
		return TYPE_BAD;
  is.read((char *)data,(int) strlen(Model3D::header()));
	is.close();
#endif

  if(((short *)data)[0] == 0x4d4d)
    return TYPE_3DS;
  else if(!strcmp((char *)data,Model3D::header()))
    return TYPE_M3D;
  
  return  TYPE_DXF;
} // end of get_file_type


void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  if(nrhs < 1) {
    plhs[0] =
        mxCreateStructMatrix(1,1,sizeof(fieldNames)/sizeof(char *),
                             fieldNames);
    make_class(&plhs[0],plhs[0]);
    return;
  }
  if(mxIsStruct(prhs[0])) {
    make_class(&plhs[0],plhs[0]);
    return;
  }
  if(!mxIsChar(prhs[0])) {
    mexPrintf("First argument should be a filename\n");
    return;
  }
  
  char filename[256];
  Model3D *model;
  mxGetString(prhs[0],filename,256);
  FileType ftype = get_file_type(filename);
  if(ftype == -1) {
    mexPrintf("Error reading file: \"%s\"\n",filename);
    return;
  }
  if(ftype == TYPE_DXF) {
    DXF *dxf = new DXF();
    dxf->setlog(mexPrintf);
    if(dxf->read_file(filename)) {
      mexPrintf("Error reading file: \"%s\"\n",filename);
      return;
    }
    model = (Model3D *)dxf;
  }
  else if(ftype == TYPE_3DS) {
    C3DS *c3ds = new C3DS;
    c3ds->setlog(mexPrintf);
    if(c3ds->read_file(filename)) {
      mexPrintf("Error reading file: \"%s\"\n",filename);
      return;
    }
    model = (Model3D *)c3ds;
  }
  else if(ftype==TYPE_M3D) {
#if !defined(WIN32)
    int fd = open(filename, O_RDONLY);
    struct stat buf;
    if(fd == -1) {
      mexPrintf("Error reading file: \"%s\"\n",filename);
      return;
    }
    fstat(fd,&buf);
    char *data = (char *)malloc(sizeof(char)*(buf.st_size+1));
    mexPrintf("data size = %d\n",buf.st_size);
    read(fd,data,buf.st_size);
    close(fd);
#else
    std::ifstream is;
    is.open(filename, std::ios::binary);
    if(is.is_open()==0) {
      mexPrintf("Error reading file: \"%s\"\n",filename);
      return;
    } 
    int fsize;
    is.seekg(0,std::ios::end);
    fsize = is.tellg();
    is.seekg(0,std::ios::beg); 
    char *data = new char[fsize];
    is.read(data,fsize);
    is.close();
#endif
    model = Model3D::unserialize((void *)data);
    free(data);
  }
  
    
  mxArray *mxLayers = 
      mxCreateStructMatrix(1,model->nLayers,
                           sizeof(lFieldNames)/sizeof(char *),
                           lFieldNames);
  
  // Create each layer from the layer struct of the Model3D class
  for(int i=0;i<model->nLayers;i++) {
    
    // First, set the colors
    mxArray *mxColor = mxCreateNumericMatrix(1,3,mxSINGLE_CLASS,mxREAL);
    memcpy(mxGetPr(mxColor),model->layers[i]->ambient,sizeof(RGB));
    mxSetFieldByNumber(mxLayers,i,4,mxColor);
      
    mxColor = mxCreateNumericMatrix(1,3,mxSINGLE_CLASS,mxREAL);
    memcpy(mxGetPr(mxColor),model->layers[i]->diffuse,sizeof(RGB));
    mxSetFieldByNumber(mxLayers,i,5,mxColor);
      
    mxColor = mxCreateNumericMatrix(1,3,mxSINGLE_CLASS,mxREAL);
    memcpy(mxGetPr(mxColor),model->layers[i]->specular,sizeof(RGB));
    mxSetFieldByNumber(mxLayers,i,6,mxColor);
      
    mxSetFieldByNumber(mxLayers,i,7,
                       mxCreateDoubleScalar(model->layers[i]->shininess));
    mxSetFieldByNumber(mxLayers,i,8,
                       mxCreateDoubleScalar(model->layers[i]->shinystrength));
    mxSetFieldByNumber(mxLayers,i,9,
                       mxCreateDoubleScalar(model->layers[i]->transparency));
    
    
    // Set the layer name
    mxSetFieldByNumber(mxLayers,i,0,
                       mxCreateString(model->layers[i]->name));
      
    // Set the list of vertices
    if(model->layers[i]->nVertices) {
      mxArray *mxVertex = 
          mxCreateNumericMatrix(3,model->layers[i]->nVertices,
                                mxSINGLE_CLASS,mxREAL);
      memcpy(mxGetPr(mxVertex),model->layers[i]->vertices,
             sizeof(float)*3*model->layers[i]->nVertices);
      mxSetFieldByNumber(mxLayers,i,1,mxVertex);
      mxArray *mxFacet = 
          mxCreateNumericMatrix(4,model->layers[i]->nFacetIdx,
                                mxINT32_CLASS,mxREAL);
      memcpy(mxGetPr(mxFacet),model->layers[i]->facetIdx,
             sizeof(int)*4*model->layers[i]->nFacetIdx);
      mxSetFieldByNumber(mxLayers,i,2,mxFacet);
    }
    
    // Set the list of facdts
    if(model->layers[i]->nFacets) {
      int dims[3];
      dims[0] = 3;
      dims[1] = 4;
      dims[2] = model->layers[i]->nFacets;
      mxArray *mxFacet = mxCreateNumericArray(3,dims,
                                              mxSINGLE_CLASS,mxREAL);
      memcpy(mxGetPr(mxFacet),model->layers[i]->facets,
             sizeof(Facet)*model->layers[i]->nFacets);
      mxSetFieldByNumber(mxLayers,i,3,mxFacet);
    }
  }
  
  // Create the output structure
  plhs[0] = mxCreateStructMatrix(1,1,sizeof(fieldNames)/sizeof(char *),fieldNames);
  mxSetFieldByNumber(plhs[0],0,0,mxCreateString(filename));
  mxSetFieldByNumber(plhs[0],0,1,mxLayers);
  mxSetFieldByNumber(plhs[0],0,2,mxCreateString(model->model_type()));
  
  // Add position variables, if necessary
  if(model->useCam == true) {
    mxArray *mx = mxCreateNumericMatrix(3,1,mxSINGLE_CLASS,mxREAL);
    memcpy(mxGetPr(mx),model->camPos,sizeof(Vector));
    mxSetFieldByNumber(plhs[0],0,3,mx);
    mx = mxCreateNumericMatrix(3,1,mxSINGLE_CLASS,mxREAL);
    memcpy(mxGetPr(mx),model->camTarget,sizeof(Vector));
    mxSetFieldByNumber(plhs[0],0,4,mx);
  }
  // Add light variables, if necessary
  if(model->lights[0]!=0) {
    int nlights=0;
    while(model->lights[nlights]!=0)
      nlights++;
     
    mxArray *mxStruct = 
        mxCreateStructMatrix(nlights,1,
                             sizeof(lightFieldNames)/sizeof(char *),
                             lightFieldNames);
    for(int i=0;i<nlights;i++) {
      mxArray *mx = mxCreateNumericMatrix(3,1,mxSINGLE_CLASS,mxREAL);
      memcpy(mxGetPr(mx),model->lights[i]->pos,sizeof(Vector));
      mxSetFieldByNumber(mxStruct,i,0,mx);
      mx = mxCreateNumericMatrix(3,1,mxSINGLE_CLASS,mxREAL);
      memcpy(mxGetPr(mx),model->lights[i]->dir,sizeof(Vector));
      mxSetFieldByNumber(mxStruct,i,1,mx);
    }
    mxSetFieldByNumber(plhs[0],0,5,mxStruct);
  }
  
  // Make the class
  make_class(&plhs[0],plhs[0]);
  
  // Delete the class to free memory
  delete model;
  return;
} // end of mexFunction